//
//  BasicPokemonInfo.swift
//  Pokemons
//
//  Created by Kristina Marchenko on 09.08.2021.
//

import Foundation

struct BasicPokemonInfo {
    let frontImage: URL?
    let backImage: URL?
    
    struct CharacteristicValue {
        let characteristic: String
        let value: String
    }
    let characteristics: [CharacteristicValue]
}
