//
//  CoordinatorFactory.swift
//  Pokemons
//
//  Created by Kristina Marchenko on 27.07.2021.
//

import UIKit

protocol CoordinatorFactory {
    func makePokemonListCoordinator(navigation: UINavigationController) -> PokemonListCoordinator
}
