//
//  ContextBuilder.swift
//  Pokemons
//
//  Created by Kristina Marchenko on 27.07.2021.
//

import Foundation

enum ContextBuilder {
    func buildContext() -> CommonContext {
        CommonContext(favoritesService: FavoritesService())
    }
}
