//
//  FetchResult.swift
//  PokemonsAPI
//
//  Created by Kristina Marchenko on 28.07.2021.
//

import Foundation

public struct FetchResult {
    public let fetched: [Pokemon]
    public let failedToFetch: [String: NetworkError]
}
