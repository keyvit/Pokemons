//
//  Pokemon.swift
//  Pokemons
//
//  Created by Kristina Marchenko on 27.07.2021.
//

import Foundation

struct Pokemon {
    let id: Int
    let name: String
    let image: URL
    let weight: Int
    let height: Int
    let order: Int
    let baseExperience: Int
    let types: [String]
    let abilities: [String]
}
