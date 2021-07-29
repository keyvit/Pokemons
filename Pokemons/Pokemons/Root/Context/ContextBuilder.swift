//
//  ContextBuilder.swift
//  Pokemons
//
//  Created by Kristina Marchenko on 27.07.2021.
//

import Foundation
import PokemonsAPI

enum ContextBuilder {
    static func buildContext() -> CommonContext {
        let pokemonProvider = PokemonProvider(
            baseURL: AppConstants.baseURL,
            defaultLimit: AppConstants.defaultPokemonPageSize
        )
        
        return CommonContext(pokemonService: PokemonService(pokemonProvider: pokemonProvider))
    }
}
