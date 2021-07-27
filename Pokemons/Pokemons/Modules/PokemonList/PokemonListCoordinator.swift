//
//  PokemonListCoordinator.swift
//  Pokemons
//
//  Created by Kristina Marchenko on 27.07.2021.
//

import UIKit

final class PokemonListCoordinator {
    init() {
        
    }
    
    func makeInitial() -> UIViewController {
        let viewController = PokemonListViewController()
        let presenter = PokemonListPresenter(view: viewController)
        viewController.presenter = presenter
        
        return viewController
    }
}
