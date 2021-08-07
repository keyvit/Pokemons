//
//  PokemonDetailsCoordinator.swift
//  Pokemons
//
//  Created by Kristina Marchenko on 29.07.2021.
//

import UIKit

final class PokemonDetailsCoordinator {
    private let pokemon: Pokemon
    
    init(pokemon: Pokemon) {
        self.pokemon = pokemon
    }
    
    func makeInitial() -> UIViewController {
        let viewController = PokemonDetailsViewController()
        let presenter = PokemonDetailsPresenter(view: viewController, pokemon: pokemon)
        viewController.presenter = presenter
        
        return viewController
    }
}
