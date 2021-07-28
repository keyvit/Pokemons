//
//  NetworkError.swift
//  PokemonsAPI
//
//  Created by Kristina Marchenko on 28.07.2021.
//

import Foundation

public enum NetworkError: Error {
    case connectionError(Error)
    case generic(GenericNetworkError)
    case other(Error)
}

public struct GenericNetworkError: Error {
    public let code: Int
    public let errorDescription: String?
    public let underlying: Error?
}
