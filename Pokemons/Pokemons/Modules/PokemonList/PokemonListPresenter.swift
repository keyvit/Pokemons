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
    var maxItemsInRowCount: Int { get }
    
    func viewDidLoad()
    func traitCollectionDidChange()
    func didShowPaginationActivityIndicator()
    func didPullToRefresh()
    func didTapPokemon(with preview: PokemonPreview)
}

final class PokemonListPresenter {
    var maxItemsInRowCount: Int {
        interfaceService.interfaceOrientation?.isPortrait ?? true ? 2 : 4
    }
    
    private weak var view: PokemonListViewType!
    
    typealias Context = HasPokemonService & CreatesInterfaceService
    private let pokemonService: PokemonServiceType
    private let interfaceService: InterfaceServiceType
    
    typealias Router = PokemonListRouter
    private let router: Router
    
    private var pokemonsToShowFromLastBatch: [PokemonPreview] = []
    
    init(view: PokemonListViewType, context: Context, router: Router) {
        self.view = view
        self.pokemonService = context.pokemonService
        self.interfaceService = context.makeInterfaceService()
        self.router = router
    }
}

// MARK: PokemonListPresenterType

extension PokemonListPresenter: PokemonListPresenterType {
    func viewDidLoad() {
        view?.setActivityIndicatorAnimating(true)
        view?.setPullToRefreshEnabled(false)
        actualizePokemonBatchLimit()
        loadInitialData()
    }
    
    func traitCollectionDidChange() {
        actualizePokemonBatchLimit()
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
            pokemonService.addToFavoritesPokemonWithId(id)
        } else {
            pokemonService.removeFromFavoritesPokemonWithId(id)
        }
        updateData(
            favorites: self.pokemonService.favoritePokemons ?? [],
            nonFavorites: self.pokemonService.nonFavoritePokemons,
            isLoadFinished: self.pokemonService.areAllPokemonsDownloaded
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
        
        pokemonService.loadFavoritePokemons { result in
            resultFavorites = result
            dispatchGroup.leave()
        }
        
        pokemonService.loadNextPokemonBatchIfNotAlready { result in
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
                    nonFavorites: self.pokemonService.nonFavoritePokemons,
                    isLoadFinished: self.pokemonService.areAllPokemonsDownloaded
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
        self.pokemonsToShowFromLastBatch.removeAll()
        var nonFavoritePreviews = nonFavorites.map { PokemonPreview(pokemon: $0, isFavorite: false) }
        adjustForRowOptimalSize(items: &nonFavoritePreviews, overallCount: nonFavoritePreviews.count)
        sections.append(PokemonList.Section(
            type: .all(areMorePokemonsAvailable: !isLoadFinished),
            pokemonPreviews: nonFavoritePreviews
        ))
        self.view?.updateData(sections)
    }
    
    func loadNextPokemonsIfNotAlready() {
        pokemonService.loadNextPokemonBatchIfNotAlready { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(pokemons):
                var items: [PokemonPreview] = []
                if !self.pokemonsToShowFromLastBatch.isEmpty {
                    items.append(contentsOf: self.pokemonsToShowFromLastBatch)
                    self.pokemonsToShowFromLastBatch.removeAll()
                }
                items.append(contentsOf: pokemons.map { PokemonPreview(pokemon: $0, isFavorite: false) })
                self.adjustForRowOptimalSize(
                    items: &items,
                    overallCount: self.pokemonService.nonFavoritePokemons.count
                )
                self.view?.appendItems(
                    items: items,
                    to: .all(areMorePokemonsAvailable: !self.pokemonService.areAllPokemonsDownloaded)
                )
            case let .failure(error):
                self.view?.hidePagingActivityIndicator()
                self.router.showAcceptableError(description: error.localizedDescription)
            }
        }
    }
    
    func adjustForRowOptimalSize(items: inout [PokemonPreview], overallCount: Int) {
        let countToShowLater = overallCount % maxItemsInRowCount
        if countToShowLater != 0 {
            for i in (1...countToShowLater).reversed() {
                let index = items.index(items.endIndex, offsetBy: -i)
                self.pokemonsToShowFromLastBatch.append(items[index])
            }
            items.removeLast(countToShowLater)
        }
    }
    
    func actualizePokemonBatchLimit() {
        pokemonService.pokemonBatchLimit = maxItemsInRowCount * 5
    }
}
