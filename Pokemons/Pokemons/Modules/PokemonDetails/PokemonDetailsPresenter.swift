//
//  PokemonDetailsPresenter.swift
//  Pokemons
//
//  Created by Kristina Marchenko on 29.07.2021.
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

protocol PokemonDetailsPresenterType {
    func viewDidLoad()
}

final class PokemonDetailsPresenter {
    private weak var view: PokemonDetailsViewType?
    private let pokemon: Pokemon
    
    init(view: PokemonDetailsViewType, pokemon: Pokemon) {
        self.view = view
        self.pokemon = pokemon
    }
}

// MARK: - PokemonDetailsPresenterType

extension PokemonDetailsPresenter: PokemonDetailsPresenterType {
    func viewDidLoad() {
        let l10n = L10n.PokemonDetails.self
        let basicInfo = BasicPokemonInfo(
            frontImage: pokemon.frontImage,
            backImage: pokemon.backImage,
            characteristics: [
                .init(characteristic: l10n.name, value: pokemon.name),
                .init(characteristic: l10n.weight, value: String(pokemon.weight)),
                .init(characteristic: l10n.height, value: String(pokemon.height)),
                .init(characteristic: l10n.order, value: String(pokemon.order)),
                .init(characteristic: l10n.baseExperience, value: String(pokemon.baseExperience))
            ]
        )
        var sections: [PokemonDetails.Section] = []
        if !pokemon.types.isEmpty {
            sections.append(PokemonDetails.Section(type: .types, items: pokemon.types))
        }
        if !pokemon.abilities.isEmpty {
            sections.append(PokemonDetails.Section(type: .abilities, items: pokemon.abilities))
        }
        view?.configure(basicInfo: basicInfo, sections: sections)
    }
}
