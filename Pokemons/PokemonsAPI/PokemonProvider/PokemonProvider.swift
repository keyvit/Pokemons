//
//  PokemonProvider.swift
//  PokemonsAPI
//
//  Created by Kristina Marchenko on 28.07.2021.
//

import Foundation
import Alamofire

public final class PokemonProvider: PokemonsAPIProvider {
    private let baseURL: URL
    private let session: Session
    private let defaultLimit: Int
    
    public init(baseURL: URL, defaultLimit: Int) {
        self.baseURL = baseURL.appendingPathComponent("pokemon", isDirectory: false)
        self.session = Session()
        self.defaultLimit = defaultLimit
    }
}

// MARK: - PokemonProviderType

extension PokemonProvider: PokemonProviderType {
    public func fetchPokemons(
        limit: Int,
        offset: Int,
        completion: @escaping (Result<PaginatedResponse<Pokemon>, NetworkError>) -> Void
    ) {
        session
            .request(request(for: .getPokemons(limit: limit, offset: offset)))
            .validate()
            .responseDecodable(completionHandler: getResponseHandler(completion: completion))
    }
    
    public func fetchPokemons(
        offset: Int,
        completion: @escaping (Result<PaginatedResponse<Pokemon>, NetworkError>) -> Void
    ) {
        fetchPokemons(limit: defaultLimit, offset: offset, completion: completion)
    }
}

private extension PokemonProvider {
    func request(for target: PokemonAPITarget) -> APIRequest {
        APIRequest(baseURL: baseURL, target: target)
    }
}
