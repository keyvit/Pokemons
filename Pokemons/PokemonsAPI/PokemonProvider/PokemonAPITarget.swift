//
//  PokemonAPITarget.swift
//  PokemonsAPI
//
//  Created by Kristina Marchenko on 28.07.2021.
//

import Foundation
import Alamofire

enum PokemonAPITarget {
    case getPokemons(limit: Int, offset: Int)
}

extension PokemonAPITarget: APITarget {
    var method: HTTPMethod {
        switch self {
        case .getPokemons:
            return .get
        }
    }
    
    var path: String {
        switch self {
        case .getPokemons:
            return ""
        }
    }
    
    var parameters: Parameters {
        switch self {
        case let .getPokemons(limit, offset):
            return .requestParameters(
                parameters: ["limit": limit, "offset": offset],
                encoding: URLEncoding.queryString
            )
        }
    }
}
