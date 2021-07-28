//
//  Pokemon.swift
//  PokemonsAPI
//
//  Created by Kristina Marchenko on 28.07.2021.
//

import Foundation

public struct Pokemon: Decodable {
    public let id: String
    public let name: String
    public let baseExperience: Int
    public let height: Int
    public let width: Int
    public let order: Int
    public let abilities: [PokemonAbility]
    public let types: [PokemonType]
    public let sprites: [PokemonSprites]
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case baseExperience = "base_experience"
        case height
        case width
        case order
        case abilities
        case types
        case sprites
    }
}

public struct PokemonAbility: Decodable {
    public let isHidden: Bool
    public let slot: Int
    public let ability: NamedAPIResource
    
    enum CodingKeys: String, CodingKey {
        case isHidden = "is_hidden"
        case slot
        case ability
    }
}

public struct PokemonType: Decodable {
    public let slot: Int
    public let type: NamedAPIResource
}

public struct PokemonSprites: Decodable {
    public let front: String
    public let back: String
    
    enum CodingKeys: String, CodingKey {
        case front = "front_default"
        case back = "back_default"
    }
}
