//
//  PokemonListCoordinator.swift
//  Pokemons
//
//  Created by Kristina Marchenko on 27.07.2021.
//

import UIKit

final class PokemonListCoordinator {
    private let context: PokemonListPresenter.Context
    private weak var navigation: ModalNavigationControllerType?
    
    init(navigation: ModalNavigationControllerType, context: PokemonListPresenter.Context) {
        self.context = context
        self.navigation = navigation
    }
    
    func makeInitial() -> UIViewController {
        let viewController = PokemonListViewController()
        let presenter = PokemonListPresenter(view: viewController, context: context, router: self)
        viewController.presenter = presenter
        
        return viewController
    }
}

// MARK: - PokemonListRouter

extension PokemonListCoordinator: PokemonListRouter {
    func showError(description: String) {
        let alert = UIAlertController(title: L10n.Common.error, message: description, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: L10n.Common.ok, style: .default))
        navigation?.present(alert, animated: true)
    }
}
