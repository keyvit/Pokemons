//
//  PokemonServiceType.swift
//  Pokemons
//
//  Created by Kristina Marchenko on 27.07.2021.
//

import Foundation

enum PokemonServiceError: LocalizedError {
    case networkError(String)
    
    var errorDescription: String? {
        switch self {
        case let .networkError(description):
            return description
        }
    }
}

struct PokemonBatch {
    let pokemons: [Pokemon]
    let isLoadFinished: Bool
}

protocol PokemonServiceType {
    var pokemons: [Pokemon] { get }
    
    func loadNextPokemonBatchIfNotAlready(
        completion: @escaping (Result<PokemonBatch, PokemonServiceError>) -> Void
    )
}

protocol HasPokemonService {
    var pokemonService: PokemonServiceType { get }
}
