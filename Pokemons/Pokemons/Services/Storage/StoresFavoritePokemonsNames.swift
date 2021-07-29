//
//  StoresFavoritePokemonsNames.swift
//  Pokemons
//
//  Created by Kristina Marchenko on 29.07.2021.
//

import Foundation

protocol StoresFavoritePokemonsNames {
    var favoritePokemonsNames: [String] { get }
    
    func saveFavoritePokemonName(_ name: String)
    func removeFavoritePokemonName(_ name: String)
}
