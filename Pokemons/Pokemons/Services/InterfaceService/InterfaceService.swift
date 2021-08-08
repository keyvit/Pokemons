//
//  InterfaceService.swift
//  Pokemons
//
//  Created by Kristina Marchenko on 09.08.2021.
//

import UIKit

protocol InterfaceServiceType {
    var interfaceOrientation: UIInterfaceOrientation? { get }
}

protocol CreatesInterfaceService {
    func makeInterfaceService() -> InterfaceServiceType
}

final class InterfaceService: InterfaceServiceType {
    var interfaceOrientation: UIInterfaceOrientation? {
        UIApplication.shared.windows.first?.windowScene?.interfaceOrientation
    }
}
