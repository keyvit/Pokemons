//
//  PokemonAPITarget.swift
//  PokemonsAPI
//
//  Created by Kristina Marchenko on 28.07.2021.
//

import Foundation
import Alamofire

enum PokemonAPITarget {
    case getPokemonsPage(limit: Int, offset: Int)
    case getPokemon(name: String)
}

extension PokemonAPITarget: APITarget {
    var method: HTTPMethod {
        switch self {
        case .getPokemonsPage, .getPokemon:
            return .get
        }
    }
    
    var path: String {
        switch self {
        case .getPokemonsPage:
            return ""
        case let .getPokemon(name):
            return name
        }
    }
    
    var parameters: Parameters {
        switch self {
        case let .getPokemonsPage(limit, offset):
            return .requestParameters(
                parameters: ["limit": limit, "offset": offset],
                encoding: URLEncoding.queryString
            )
        case .getPokemon:
            return .requestPlain
        }
    }
}
