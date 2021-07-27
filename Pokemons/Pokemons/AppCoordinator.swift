//
//  AppCoordinator.swift
//  Pokemons
//
//  Created by Kristina Marchenko on 27.07.2021.
//

import UIKit

final class AppCoordinator {
    private let navigation: SingleNavigationControllerType
    
    init(navigation: SingleNavigationControllerType) {
        self.navigation = navigation
    }
    
    func run() {
        let viewController = PokemonListViewController()
        navigation.put(viewController)
    }
}
