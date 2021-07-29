//
//  PokemonListPresenter.swift
//  Pokemons
//
//  Created by Kristina Marchenko on 27.07.2021.
//

import Foundation

enum PokemonList {
    typealias Item = PokemonPreview
    
    enum SectionType: Hashable {
        case favorite
        case all(areMorePokemonsAvailable: Bool)
        
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
    func showError(description: String)
}

protocol PokemonListPresenterType: PokemonCollectionViewCellDelegate {
    func viewDidLoad()
    func didShowPaginationActivityIndicator()
}

final class PokemonListPresenter {
    private weak var view: PokemonListViewType!
    
    typealias Context = HasPokemonService
    private let context: Context
    
    typealias Router = PokemonListRouter
    private let router: Router
    
    init(view: PokemonListViewType, context: Context, router: Router) {
        self.view = view
        self.context = context
        self.router = router
    }
}

// MARK: - PokemonListPresenterType

extension PokemonListPresenter: PokemonListPresenterType {
    func viewDidLoad() {
        loadNextPokemonsIfNotAlready()
    }
    
    func didShowPaginationActivityIndicator() {
        loadNextPokemonsIfNotAlready()
    }
}

// MARK: - PokemonCollectionViewCellDelegate

extension PokemonListPresenter {
    func pokemonCollectionViewCell(withId id: Int, didTapFavorite isFavorite: Bool) {
        
    }
}

// MARK: - Decomposition

private extension PokemonListPresenter {
    func loadNextPokemonsIfNotAlready() {
        context.pokemonService.loadNextPokemonBatchIfNotAlready { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(pokemonBatch):
                let data: [PokemonList.Section] = [
                    PokemonList.Section(
                        type: .all(areMorePokemonsAvailable: !pokemonBatch.isLoadFinished),
                        pokemonPreviews: self.context.pokemonService.pokemons.map {
                            PokemonPreview(pokemon: $0)
                        }
                    )
                ]
                self.view?.updateData(data)
            case let .failure(error):
                self.view?.hidePagingActivityIndicator()
                self.router.showError(description: error.localizedDescription)
            }
        }
    }
}
