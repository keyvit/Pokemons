//
//  PokemonList.swift
//  Pokemons
//
//  Created by Kristina Marchenko on 09.08.2021.
//

import Foundation

// MARK: - PokemonList

enum PokemonList {
    typealias View = PokemonListViewType
    typealias Item = PokemonPreview
    typealias Presenter = PokemonListPresenterType
    
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
