//
//  CommonContext.swift
//  Pokemons
//
//  Created by Kristina Marchenko on 27.07.2021.
//

import Foundation

final class CommonContext {
    let favoritesService: FavoritesServiceType
    
    init(favoritesService: FavoritesServiceType) {
        self.favoritesService = favoritesService
    }
}

// MARK: - CoordinatorFactory

extension CommonContext: CoordinatorFactory {
    func makePokemonListCoordinator() -> PokemonListCoordinator {
        PokemonListCoordinator()
    }
}
