//
//  PokemonService.swift
//  Pokemons
//
//  Created by Kristina Marchenko on 27.07.2021.
//

import Foundation
import PokemonsAPI

final class PokemonService {
    private(set) var pokemons: [Pokemon] = []
    
    private let pokemonProvider: PokemonProviderType
    
    // TODO: Save favorite pokemons locally
    private var favoritePokemons: [Pokemon] = []
    private var allPossiblePokemonCount: Int?
    private let limit = AppConstants.defaultPokemonPageSize
    private var offset = 0
    private var isPokemonPageDownloadInProgress = false
    
    private struct UnfinishedPokemonPageDownload {
        let fetched: [Pokemon]
        let failedToFetch: [String]
    }
    private var unfinishedDownload: UnfinishedPokemonPageDownload?
    
    init(pokemonProvider: PokemonProviderType) {
        self.pokemonProvider = pokemonProvider
    }
}

// MARK: - PokemonServiceType

extension PokemonService: PokemonServiceType {
    func loadNextPokemonBatchIfNotAlready(
        completion: @escaping (Result<PokemonBatch, PokemonServiceError>) -> Void
    ) {
        guard !isPokemonPageDownloadInProgress else { return }
        isPokemonPageDownloadInProgress = true
        
        let completion: (Result<PokemonBatch, PokemonServiceError>) -> Void = { [weak self] result in
            self?.isPokemonPageDownloadInProgress = false
            completion(result)
        }
        
        let pokemonFetchCompletion: (FetchResult) -> Void = { [weak self] result in
            guard let self = self else { return }
            
            var fetched = result.fetched.map { Pokemon(from: $0) }
            self.unfinishedDownload.map { fetched.append(contentsOf: $0.fetched) }
            
            if result.failedToFetch.isEmpty {
                self.offset += fetched.count
                self.pokemons.append(contentsOf: fetched.sorted(by: { $0.order < $1.order }))
                self.unfinishedDownload = nil
                let isLoadFinished = fetched.count < self.limit
                    || self.offset >= self.allPossiblePokemonCount ?? Int.max
                completion(.success(PokemonBatch(pokemons: fetched, isLoadFinished: isLoadFinished)))
            } else {
                self.unfinishedDownload = UnfinishedPokemonPageDownload(
                    fetched: fetched,
                    failedToFetch: result.failedToFetch.keys.map { $0 }
                )
                result.failedToFetch.values.first.map {
                    completion(.failure(Self.map(networkError: $0)))
                }
            }
        }
        
        if let unfinishedDownload = unfinishedDownload {
            pokemonProvider.fetchPokemons(
                names: unfinishedDownload.failedToFetch,
                completion: pokemonFetchCompletion
            )
        } else {
            pokemonProvider.fetchPokemonsPage(offset: offset) { [weak self] result in
                switch result {
                case let .success(response):
                    self?.allPossiblePokemonCount = response.count
                    let names = response.results.map { $0.name }
                    self?.pokemonProvider.fetchPokemons(names: names, completion: pokemonFetchCompletion)
                case let .failure(error):
                    completion(.failure(Self.map(networkError: error)))
                }
            }
        }
    }
}

// MARK: - Error Mapping

private extension PokemonService {
    static func map(networkError: NetworkError) -> PokemonServiceError {
        let description: String
        switch networkError {
        case let .connectionError(error):
            description = error.localizedDescription
        case .generic:
            description = L10n.PokemonFetch.Error.unknown
        case .other:
            description = L10n.PokemonFetch.Error.unknown
        }
        
        return .networkError(description)
    }
}
