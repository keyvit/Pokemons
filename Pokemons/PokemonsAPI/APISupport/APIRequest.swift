//
//  APIRequest.swift
//  PokemonsAPI
//
//  Created by Kristina Marchenko on 28.07.2021.
//

import Foundation
import Alamofire

struct APIRequest: URLRequestConvertible {
    let baseURL: URL
    let target: APITarget
}

extension APIRequest {
    func asURLRequest() throws -> URLRequest {
        var request = try URLRequest(url: baseURL.appendingPathComponent(target.path), method: target.method)
        
        switch target.parameters {
        case let .requestParameters(parameters, encoding):
            request = try encoding.encode(request, with: parameters)
        }
        
        return request
    }
}

