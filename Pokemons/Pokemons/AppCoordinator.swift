//
//  AppCoordinator.swift
//  Pokemons
//
//  Created by Kristina Marchenko on 27.07.2021.
//

import UIKit

final class AppCoordinator {
    private let navigation: SingleNavigationControllerType
    private lazy var context: CommonContext = ContextBuilder.buildContext()
    
    init(navigation: SingleNavigationControllerType) {
        self.navigation = navigation
    }
    
    func run() {
        let coordinator = context.makePokemonListCoordinator()
        let navigationController = UINavigationController(rootViewController: coordinator.makeInitial())
        navigation.put(navigationController)
    }
}
