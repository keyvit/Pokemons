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

protocol PokemonServiceType: AnyObject {
    var favoritePokemons: [Pokemon]? { get }
    var nonFavoritePokemons: [Pokemon] { get }
    var allPokemons: [Pokemon] { get }
    var areAllPokemonsDownloaded: Bool { get }
    var pokemonBatchLimit: Int { get set }
    
    func loadFavoritePokemons(completion: @escaping (Result<[Pokemon], PokemonServiceError>) -> Void)
    func loadNextPokemonBatchIfNotAlready(
        completion: @escaping (Result<[Pokemon], PokemonServiceError>) -> Void
    )
    
    func addToFavoritesPokemonWithId(_ id: Int)
    func removeFromFavoritesPokemonWithId(_ id: Int)
}

protocol HasPokemonService {
    var pokemonService: PokemonServiceType { get }
}
