//
//  ModalNavigationControllerType.swift
//  Pokemons
//
//  Created by Kristina Marchenko on 28.07.2021.
//

import UIKit

protocol ModalNavigationControllerType: AnyObject {
    typealias Item = UIViewController

    var topPresentedItem: ModalNavigationControllerType? { get }
    
    func present(_ item: Item, animated: Bool, completion: (() -> Void)?)
    func dismiss(animated: Bool, completion: (() -> Void)?)
}

extension ModalNavigationControllerType {
    func present(_ item: Item, animated: Bool) {
        present(item, animated: animated, completion: nil)
    }
}

extension UIViewController: ModalNavigationControllerType {
    var topPresentedItem: ModalNavigationControllerType? {
        var item = self
        while let presented = item.presentedViewController {
            item = presented
        }
        return item
    }
}
