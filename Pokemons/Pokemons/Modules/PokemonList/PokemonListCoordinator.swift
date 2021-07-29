//
//  PokemonListCoordinator.swift
//  Pokemons
//
//  Created by Kristina Marchenko on 27.07.2021.
//

import UIKit

final class PokemonListCoordinator {
    typealias Context = CoordinatorFactory & PokemonListPresenter.Context
    private let context: Context
    private weak var navigation: UINavigationController?
    
    init(navigation: UINavigationController, context: Context) {
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
    func showAcceptableError(description: String) {
        let alert = UIAlertController(title: L10n.Common.error, message: description, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: L10n.Common.ok, style: .cancel))
        navigation?.present(alert, animated: true)
    }
    
    func showRetriableError(
        description: String,
        didChooseAccept: @escaping () -> Void,
        didChooseRetry: @escaping () -> Void
    ) {
        let alert = UIAlertController(title: L10n.Common.error, message: description, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: L10n.Common.ok, style: .cancel) { _ in
            didChooseAccept()
        })
        alert.addAction(UIAlertAction(title: L10n.Common.retry, style: .default) { _ in
            didChooseRetry()
        })
        navigation?.present(alert, animated: true)
    }
    
    func showPokemonDetails(_ pokemon: Pokemon) {
    }
}
