//
//  CoordinatorFactory.swift
//  Pokemons
//
//  Created by Kristina Marchenko on 27.07.2021.
//

import Foundation

protocol CoordinatorFactory {
    func makePokemonListCoordinator(navigation: ModalNavigationControllerType) -> PokemonListCoordinator
}
