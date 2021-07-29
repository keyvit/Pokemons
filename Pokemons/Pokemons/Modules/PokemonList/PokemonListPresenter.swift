//
//  PokemonListPresenter.swift
//  Pokemons
//
//  Created by Kristina Marchenko on 27.07.2021.
//

import Foundation

// MARK: - PokemonPreview

struct PokemonPreview {
    fileprivate let pokemon: Pokemon
    
    var id: Int {
        pokemon.id
    }
    
    var name: String {
        pokemon.name
    }
    
    var image: URL? {
        pokemon.frontImage
    }
    
    let isFavorite: Bool
}

// MARK: Hashable

extension PokemonPreview: Hashable {
    static func == (lhs: PokemonPreview, rhs: PokemonPreview) -> Bool {
        lhs.id == rhs.id && lhs.name == rhs.name && lhs.image == rhs.image && lhs.isFavorite == rhs.isFavorite
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
        hasher.combine(image)
        hasher.combine(isFavorite)
    }
}

// MARK: - PokemonList

enum PokemonList {
    typealias Item = PokemonPreview
    
    enum SectionType: Hashable {
        case favorite
        case all(areMorePokemonsAvailable: Bool)
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(self == .favorite ? 0 : 1)
        }
        
        static func == (lhs: Self, rhs: Self) -> Bool {
            switch (lhs, rhs) {
            case (.favorite, .favorite), (.all, .all):
                return true
            default:
                return false
            }
        }
        
        var title: String {
            switch self {
            case .all:
                return L10n.PokemonList.Section.all
            case .favorite:
                return L10n.PokemonList.Section.favorite
            }
        }
    }

    struct Section {        
        let type: SectionType
        let pokemonPreviews: [PokemonPreview]
    }
}

protocol PokemonListRouter {
    func showAcceptableError(description: String)
    func showRetriableError(
        description: String,
        didChooseAccept: @escaping () -> Void,
        didChooseRetry: @escaping () -> Void
    )
    
    func showPokemonDetails(_ pokemon: Pokemon)
}

protocol PokemonListPresenterType: PokemonCollectionViewCellDelegate {
    func viewDidLoad()
    func didShowPaginationActivityIndicator()
    func didPullToRefresh()
    func didTapPokemon(with preview: PokemonPreview)
}

final class PokemonListPresenter {
    private weak var view: PokemonListViewType!
    
    typealias Context = HasPokemonService
    private let context: Context
    
    typealias Router = PokemonListRouter
    private let router: Router
    
    private var pokemonToShowFromLastBatch: PokemonPreview?
    
    init(view: PokemonListViewType, context: Context, router: Router) {
        self.view = view
        self.context = context
        self.router = router
    }
}

// MARK: PokemonListPresenterType

extension PokemonListPresenter: PokemonListPresenterType {
    func viewDidLoad() {
        view?.setActivityIndicatorAnimating(true)
        view?.setPullToRefreshEnabled(false)
        loadInitialData()
    }
    
    func didShowPaginationActivityIndicator() {
        loadNextPokemonsIfNotAlready()
    }
    
    func didPullToRefresh() {
        loadInitialData()
    }
    
    func didTapPokemon(with preview: PokemonPreview) {
        router.showPokemonDetails(preview.pokemon)
    }
}

// MARK: PokemonCollectionViewCellDelegate

extension PokemonListPresenter {
    func pokemonCollectionViewCell(withId id: Int, didTapFavorite isFavorite: Bool) {
        if isFavorite {
            context.pokemonService.addToFavoritesPokemonWithId(id)
        } else {
            context.pokemonService.removeFromFavoritesPokemonWithId(id)
        }
        self.updateData(
            favorites: self.context.pokemonService.favoritePokemons ?? [],
            nonFavorites: self.context.pokemonService.nonFavoritePokemons,
            isLoadFinished: self.context.pokemonService.areAllPokemonsDownloaded
        )
    }
}

// MARK: Decomposition

private extension PokemonListPresenter {
    func loadInitialData() {
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        dispatchGroup.enter()
        
        var resultFavorites: Result<[Pokemon], PokemonServiceError>?
        var resultNonFavorites: Result<[Pokemon], PokemonServiceError>?
        
        context.pokemonService.loadFavoritePokemons { result in
            resultFavorites = result
            dispatchGroup.leave()
        }
        
        context.pokemonService.loadNextPokemonBatchIfNotAlready { result in
            resultNonFavorites = result
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main) { [weak self] in
            guard let self = self,
                  let resultFavorites = resultFavorites,
                  let resultNonFavorites = resultNonFavorites
            else { return }
            
            self.view?.setActivityIndicatorAnimating(false)
            self.view?.stopRefreshControlIfAny()
            
            let processError: (Error) -> Void = { error in
                self.router.showRetriableError(
                    description: error.localizedDescription,
                    didChooseAccept: {
                        self.view?.setPullToRefreshEnabled(true)
                    },
                    didChooseRetry: {
                        self.view?.setPullToRefreshEnabled(false)
                        self.loadInitialData()
                    }
                )
            }
            
            switch (resultFavorites, resultNonFavorites) {
            case (.success(let favorites), .success):
                self.updateData(
                    favorites: favorites,
                    nonFavorites: self.context.pokemonService.nonFavoritePokemons,
                    isLoadFinished: self.context.pokemonService.areAllPokemonsDownloaded
                )
                self.view?.setPullToRefreshEnabled(false)
            case (.success, .failure(let error)), (.failure(let error), .success):
                print("Failed to load initial data: \(error)")
                processError(error)
            case (.failure(let error1), .failure(let error2)):
                print("Failed to load initial data: \(error1), \(error2)")
                processError(error1)
            }
        }
    }
    
    func updateData(favorites: [Pokemon], nonFavorites: [Pokemon], isLoadFinished: Bool) {
        var sections: [PokemonList.Section] = []
        if !favorites.isEmpty {
            sections.append(PokemonList.Section(
                type: .favorite,
                pokemonPreviews: favorites.map { PokemonPreview(pokemon: $0, isFavorite: true) }
            ))
        }
        self.pokemonToShowFromLastBatch = nil
        var nonFavoritePreviews = nonFavorites.map { PokemonPreview(pokemon: $0, isFavorite: false) }
        if !nonFavoritePreviews.count.isMultiple(of: 2) {
            self.pokemonToShowFromLastBatch = nonFavoritePreviews.removeLast()
        }
        sections.append(PokemonList.Section(
            type: .all(areMorePokemonsAvailable: !isLoadFinished),
            pokemonPreviews: nonFavoritePreviews
        ))
        self.view?.updateData(sections)
    }
    
    func loadNextPokemonsIfNotAlready() {
        context.pokemonService.loadNextPokemonBatchIfNotAlready { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(pokemons):
                var items: [PokemonPreview] = []
                if let lastBatchPokemon = self.pokemonToShowFromLastBatch {
                    items.append(lastBatchPokemon)
                    self.pokemonToShowFromLastBatch = nil
                }
                items.append(contentsOf: pokemons.map { PokemonPreview(pokemon: $0, isFavorite: false) })
                if !self.context.pokemonService.nonFavoritePokemons.count.isMultiple(of: 2) {
                    self.pokemonToShowFromLastBatch = items.removeLast()
                }
                self.view?.appendItems(
                    items: items,
                    to: .all(areMorePokemonsAvailable: !self.context.pokemonService.areAllPokemonsDownloaded)
                )
            case let .failure(error):
                self.view?.hidePagingActivityIndicator()
                self.router.showAcceptableError(description: error.localizedDescription)
            }
        }
    }
}
