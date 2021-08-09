//
//  Palette.swift
//  Pokemons
//
//  Created by Kristina Marchenko on 09.08.2021.
//

import UIKit

protocol PaletteType {
    var outlineColor: UIColor { get }
}

struct Palette: PaletteType {
    var outlineColor: UIColor {
        UIColor { traitCollection in
            if traitCollection.userInterfaceStyle == .dark {
                return UIColor.systemGray2
            } else {
                return UIColor.black
            }
        }
    }
}

typealias DefaultPalette = Palette
