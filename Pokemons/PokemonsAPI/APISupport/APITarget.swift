//
//  APITarget.swift
//  PokemonsAPI
//
//  Created by Kristina Marchenko on 28.07.2021.
//

import Foundation
import Alamofire

protocol APITarget {
    var method: Alamofire.HTTPMethod { get }
    var path: String { get }
    var parameters: Parameters { get }
}

/// To be extended when needed
enum Parameters {
    case requestPlain
    case requestParameters(parameters: [String: Any], encoding: ParameterEncoding)
}
