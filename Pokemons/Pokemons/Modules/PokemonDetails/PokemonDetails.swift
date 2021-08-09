//
//  PokemonDetails.swift
//  Pokemons
//
//  Created by Kristina Marchenko on 09.08.2021.
//

import Foundation

enum PokemonDetails {
    typealias Item = String
    
    enum SectionType: Int {
        case types
        case abilities
        
        var title: String {
            switch self {
            case .types:
                return L10n.PokemonDetails.types
            case .abilities:
                return L10n.PokemonDetails.abilities
            }
        }
    }
    
    struct Section {
        let type: SectionType
        let items: [Item]
    }
}
