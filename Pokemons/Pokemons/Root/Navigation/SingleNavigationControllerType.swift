//
//  SingleNavigationControllerType.swift
//  Pokemons
//
//  Created by Kristina Marchenko on 27.07.2021.
//

import UIKit

protocol SingleNavigationControllerType: AnyObject {
    typealias Item = UIViewController
    
    var item: Item? { get }
    
    func put(_ item: Item)
}

extension UIWindow: SingleNavigationControllerType {
    var item: Item? {
        rootViewController
    }
    
    func put(_ item: Item) {
        rootViewController = item
    }
}
