//
//  PokemonProviderType.swift
//  PokemonsAPI
//
//  Created by Kristina Marchenko on 28.07.2021.
//

import Foundation

public protocol PokemonProviderType {
    func fetchPokemonsPage(
        limit: Int,
        offset: Int,
        completion: @escaping (Result<PaginatedResponse, NetworkError>) -> Void
    )
    
    func fetchPokemonsPage(
        offset: Int,
        completion: @escaping (Result<PaginatedResponse, NetworkError>) -> Void
    )
    
    func fetchPokemons(names: [String], completion: @escaping (FetchResult) -> Void)
}
