//
//  CommonContext.swift
//  Pokemons
//
//  Created by Kristina Marchenko on 27.07.2021.
//

import UIKit

final class CommonContext: HasPokemonService {
    let pokemonService: PokemonServiceType
    
    init(pokemonService: PokemonServiceType) {
        self.pokemonService = pokemonService
    }
}

// MARK: - CoordinatorFactory

extension CommonContext: CoordinatorFactory {
    func makePokemonListCoordinator(navigation: UINavigationController) -> PokemonListCoordinator {
        PokemonListCoordinator(navigation: navigation, context: self)
    }
    
    func makePokemonDetailsCoordinator(for pokemon: Pokemon) -> PokemonDetailsCoordinator {
        PokemonDetailsCoordinator(pokemon: pokemon)
    }
}
