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
    public func fetchPokemonsPage(
        limit: Int,
        offset: Int,
        completion: @escaping (Result<PaginatedResponse, NetworkError>) -> Void
    ) {
        session
            .request(request(for: .getPokemonsPage(limit: limit, offset: offset)))
            .validate()
            .responseDecodable(completionHandler: getResponseHandler(completion: completion))
    }
    
    public func fetchPokemonsPage(
        offset: Int,
        completion: @escaping (Result<PaginatedResponse, NetworkError>) -> Void
    ) {
        fetchPokemonsPage(limit: defaultLimit, offset: offset, completion: completion)
    }
    
    public func fetchPokemons(names: [String], completion: @escaping (FetchResult) -> Void) {
        var fetched: [Pokemon] = []
        var failedToFetch: [String: NetworkError] = [:]
        let requestsToFinish = names.count
        var requestsFinished = 0
        
        let requestCompletion: (String, Result<Pokemon, NetworkError>) -> Void = { name, result in
            requestsFinished += 1
            switch result {
            case let .success(pokemon):
                fetched.append(pokemon)
            case let .failure(error):
                failedToFetch[name] = error
            }
            if requestsFinished == requestsToFinish {
                completion(FetchResult(fetched: fetched, failedToFetch: failedToFetch))
            }
        }
        
        names.forEach { name in
            let completion: (Result<Pokemon, NetworkError>) -> Void = { result in
                requestCompletion(name, result)
            }
            session
                .request(request(for: .getPokemon(name: name)))
                .validate()
                .responseDecodable(completionHandler: getResponseHandler(completion: completion))
        }
    }
}

private extension PokemonProvider {
    func request(for target: PokemonAPITarget) -> APIRequest {
        APIRequest(baseURL: baseURL, target: target)
    }
}
