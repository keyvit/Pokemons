//
//  PokemonPreview.swift
//  Pokemons
//
//  Created by Kristina Marchenko on 27.07.2021.
//

import Foundation

struct PokemonPreview: Hashable {
    let id: Int
    let name: String
    let image: URL?
    let isFavorite: Bool
}

extension PokemonPreview {
    init(pokemon: Pokemon) {
        self.init(id: pokemon.id, name: pokemon.name, image: pokemon.frontImage, isFavorite: false) // FIXME: 
    }
}
