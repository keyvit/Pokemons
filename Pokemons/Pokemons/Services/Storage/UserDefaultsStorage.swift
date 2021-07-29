//
//  UserDefaultsStorage.swift
//  Pokemons
//
//  Created by Kristina Marchenko on 29.07.2021.
//

import Foundation

private enum Keys: String, CaseIterable {
    case favorites
}

final class UserDefaultsStorage {
    private let defaults = UserDefaults.standard
}

// MARK: - StoresFavoritePokemons

extension UserDefaultsStorage: StoresFavoritePokemonsNames {
    var favoritePokemonsNames: [String] {
        defaults.stringArray(forKey: Keys.favorites.rawValue) ?? []
    }
    
    func saveFavoritePokemonName(_ name: String) {
        var favorites = defaults.stringArray(forKey: Keys.favorites.rawValue) ?? []
        favorites.append(name)
        defaults.setValue(favorites, forKey: Keys.favorites.rawValue)
    }
    
    func removeFavoritePokemonName(_ name: String) {
        guard var favorites = defaults.stringArray(forKey: Keys.favorites.rawValue) else { return }
        favorites.removeAll(where: { $0 == name })
        defaults.setValue(favorites, forKey: Keys.favorites.rawValue)
    }
}
