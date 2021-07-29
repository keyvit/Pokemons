//
//  Pokemon+API.swift
//  Pokemons
//
//  Created by Kristina Marchenko on 28.07.2021.
//

import Foundation
import PokemonsAPI

extension Pokemon {
    init(from model: PokemonsAPI.Pokemon) {
        self.init(
            id: model.id,
            name: model.name,
            frontImage: URL(string: model.sprites.front),
            backImage: URL(string: model.sprites.back),
            weight: model.weight,
            height: model.weight,
            order: model.order,
            baseExperience: model.baseExperience,
            types: model.types.map { $0.type.name },
            abilities: model.abilities.map { $0.ability.name }
        )
    }
}
