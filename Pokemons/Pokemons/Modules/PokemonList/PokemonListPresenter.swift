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
        case all
        
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

protocol PokemonListPresenterType: PokemonCollectionViewCellDelegate {
    func viewDidLoad()
}

final class PokemonListPresenter {
    private weak var view: PokemonListViewType!
    
    init(view: PokemonListViewType) {
        self.view = view
    }
}

// MARK: - PokemonListPresenterType

extension PokemonListPresenter: PokemonListPresenterType {
    func viewDidLoad() {
    }
}

// MARK: - PokemonCollectionViewCellDelegate

extension PokemonListPresenter {
    func pokemonCollectionViewCell(withId id: Int, didTapFavorite isFavorite: Bool) {
        
    }
}
