//
//  PaginatedResponse.swift
//  PokemonsAPI
//
//  Created by Kristina Marchenko on 28.07.2021.
//

import Foundation

public struct PaginatedResponse<ResultType: Decodable>: Decodable {
    public let count: Int
    public let results: [ResultType]
}
