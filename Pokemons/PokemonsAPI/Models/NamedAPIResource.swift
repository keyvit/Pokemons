//
//  NamedAPIResource.swift
//  PokemonsAPI
//
//  Created by Kristina Marchenko on 28.07.2021.
//

import Foundation

public struct NamedAPIResource: Decodable {
    public let name: String
    public let url: String
}
