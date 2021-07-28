//
//  PokemonProviderType.swift
//  PokemonsAPI
//
//  Created by Kristina Marchenko on 28.07.2021.
//

import Foundation

public protocol PokemonProviderType {
    func fetchPokemons(
        limit: Int,
        offset: Int,
        completion: @escaping (Result<PaginatedResponse<Pokemon>, NetworkError>) -> Void
    )
    
    func fetchPokemons(
        offset: Int,
        completion: @escaping (Result<PaginatedResponse<Pokemon>, NetworkError>) -> Void
    )
}
