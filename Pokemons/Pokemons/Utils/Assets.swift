//
//  Assets.swift
//  Pokemons
//
//  Created by Kristina Marchenko on 27.07.2021.
//

import UIKit

/// To be generated automatically using i.e. SwiftGen in case project gets bigger.

struct ImageAsset {
    private let name: String
    
    fileprivate enum ImageAssetType {
        case system(UIImage.Configuration?)
        case custom
    }
    private let type: ImageAssetType
    
    fileprivate init(name: String, type: ImageAssetType = .custom) {
        self.name = name
        self.type = type
    }
    
    var image: UIImage {
        let image: UIImage?
        switch type {
        case .custom:
            image = UIImage(named: name)
        case let .system(config):
            image = UIImage(systemName: name, withConfiguration: config)
        }
        if let image = image {
            return image
        } else {
            fatalError(#"Unable to load image "\#(name)"#)
        }
    }
}

enum Asset {
    static let pokeball = ImageAsset(name: "pokeball")
    static func like(configuration: UIImage.Configuration?) -> ImageAsset {
        ImageAsset(name: "suit.heart.fill", type: .system(configuration))
    }
}

enum L10n {
    private static let defaultTable = "Localizable"
    
    enum FavoriteButton {
        static let like = L10n.tr(defaultTable, "favorite_button.like")
        static let dislike = L10n.tr(defaultTable, "favorite_button.dislike")
    }
    enum PokemonList {
        enum Section {
            static let all = L10n.tr(defaultTable, "pokemon_list.section.all")
            static let favorite = L10n.tr(defaultTable, "pokemon_list.section.favorite")
        }
    }
    enum PokemonDetails {
        static let name = L10n.tr(defaultTable, "pokemon_details.name")
        static let weight = L10n.tr(defaultTable, "pokemon_details.weight")
        static let height = L10n.tr(defaultTable, "pokemon_details.height")
        static let order = L10n.tr(defaultTable, "pokemon_details.order")
        static let baseExperience = L10n.tr(defaultTable, "pokemon_details.base_experience")
        static let types = L10n.tr(defaultTable, "pokemon_details.types")
        static let abilities = L10n.tr(defaultTable, "pokemon_details.abilities")
    }
}

private extension L10n {
  static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    let format = Bundle.main.localizedString(forKey: key, value: nil, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}
