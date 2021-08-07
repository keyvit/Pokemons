//
//  PokemonDetailsPresenter.swift
//  Pokemons
//
//  Created by Kristina Marchenko on 29.07.2021.
//

import Foundation

enum PokemonDetails {
    typealias Item = String
    
    struct BasicInfo {
        let frontImage: URL?
        let backImage: URL?
        let characteristics: [String: String]
    }
    
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
        let basicInfo = PokemonDetails.BasicInfo(
            frontImage: pokemon.frontImage,
            backImage: pokemon.backImage,
            characteristics: [
                l10n.name: pokemon.name,
                l10n.weight: String(pokemon.weight),
                l10n.height: String(pokemon.height),
                l10n.order: String(pokemon.order),
                l10n.baseExperience: String(pokemon.baseExperience)
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
