//
//  PokemonFetcher.swift
//  Pokemons
//
//  Created by Kristina Marchenko on 29.07.2021.
//

import Foundation
import PokemonsAPI

// MARK: - PokemonFetcher

final class PokemonFetcher {
    private let pokemonProvider: PokemonProviderType
    
    private var fetched: [Pokemon]
    private var namesToFetch: [String]
    
    init(pokemonProvider: PokemonProviderType, namesToFetch: [String]) {
        self.pokemonProvider = pokemonProvider
        self.fetched = []
        self.namesToFetch = namesToFetch
    }
    
    func fetch(completion: @escaping (Result<[Pokemon], NetworkError>) -> Void) {
        guard !namesToFetch.isEmpty else {
            completion(.success(fetched))
            return
        }
        
        pokemonProvider.fetchPokemons(names: namesToFetch) { [weak self] result in
            guard let self = self else { return }
            
            if !result.fetched.isEmpty {
                self.fetched.append(contentsOf: result.fetched.map { Pokemon(from: $0) })
            }
            
            if result.failedToFetch.isEmpty {
                self.namesToFetch = []
                completion(.success(self.fetched))
            } else {
                self.namesToFetch = result.failedToFetch.keys.map { $0 }
                result.failedToFetch.values.first.map {
                    completion(.failure($0))
                }
            }
        }
    }
}

// MARK: - NonFavoritePokemonBatchFetcher

private struct PokemonBatch {
    let namesToFetch: [String]
    let namesToIgnore: [String]
    let resultOffset: Int
}

struct PokemonBatchFetchResult {
    let pokemons: [Pokemon]
    let allPossiblePokemonCount: Int
    let resultOffset: Int
}

final class NonFavoritePokemonBatchFetcher {
    private let pokemonProvider: PokemonProviderType
    private let limit: Int
    
    private let initialOffset: Int
    private var resultOffset: Int
    private var allPossiblePokemonCount: Int?
    
    private var pokemonFetcher: PokemonFetcher?
    private var namesToIgnore: [String]
    private var previouslyIgnoredPokemons: [Pokemon]
    
    init(pokemonProvider: PokemonProviderType, initialOffset: Int, limit: Int, namesToIgnore: [String]) {
        self.pokemonProvider = pokemonProvider
        self.initialOffset = initialOffset
        self.resultOffset = initialOffset
        self.limit = limit
        self.namesToIgnore = namesToIgnore
        self.previouslyIgnoredPokemons = []
    }
    
    func fetchNext(completion: @escaping (Result<PokemonBatchFetchResult, NetworkError>) -> Void) {
        let completion: (Result<[Pokemon], NetworkError>) -> Void = { [weak self] result in
            guard let self = self else { return }
            let withMappedSuccess = result.map { fetched in
                return PokemonBatchFetchResult(
                    pokemons: fetched + self.previouslyIgnoredPokemons.filter {
                        self.namesToIgnore.contains($0.name)
                    },
                    allPossiblePokemonCount: self.allPossiblePokemonCount ?? 0,
                    resultOffset: self.resultOffset
                )
            }
            completion(withMappedSuccess)
        }
        
        if let pokemonFetcher = pokemonFetcher {
            pokemonFetcher.fetch(completion: completion)
            return
        }
        
        fetchNonFavoritePokemonsNames(
            limit: limit,
            offset: initialOffset,
            desiredCount: limit,
            fetched: [],
            ignored: [],
            completion: { [weak self] result in
                guard let self = self else { return }
                switch result {
                case let .success(batch):
                    let pokemonFetcher = PokemonFetcher(
                        pokemonProvider: self.pokemonProvider,
                        namesToFetch: batch.namesToFetch
                    )
                    self.resultOffset = batch.resultOffset
                    self.namesToIgnore = batch.namesToIgnore
                    self.pokemonFetcher = pokemonFetcher
                    pokemonFetcher.fetch(completion: completion)
                case let .failure(error):
                    completion(.failure(error))
                }
            }
        )
    }
    
    func markPokemonAsIncluded(_ pokemon: Pokemon) {
        previouslyIgnoredPokemons.append(pokemon)
    }
}

// MARK: Decomposition

private extension NonFavoritePokemonBatchFetcher {
    func fetchNonFavoritePokemonsNames(
        limit: Int,
        offset: Int,
        desiredCount: Int,
        fetched: [String],
        ignored: [String],
        completion: @escaping (Result<PokemonBatch, NetworkError>) -> Void
    ) {
        pokemonProvider.fetchPokemonsPage(limit: limit, offset: offset) { [weak self] result in
            switch result {
            case let .success(response):
                guard let self = self else { return }
                self.allPossiblePokemonCount = response.count
                
                let allCurrentlyFetched = response.results.map { $0.name }
                let overallFetched = fetched + allCurrentlyFetched.filter { !self.namesToIgnore.contains($0) }
                let overallIgnored = ignored + allCurrentlyFetched.filter { self.namesToIgnore.contains($0) }
                if allCurrentlyFetched.count == limit && overallFetched.count < desiredCount {
                    self.fetchNonFavoritePokemonsNames(
                        limit: self.limit / 2,
                        offset: offset + limit,
                        desiredCount: desiredCount,
                        fetched: overallFetched,
                        ignored: overallIgnored,
                        completion: completion
                    )
                } else {
                    let batch = PokemonBatch(
                        namesToFetch: overallFetched,
                        namesToIgnore: overallIgnored,
                        resultOffset: offset + allCurrentlyFetched.count
                    )
                    completion(.success(batch))
                }
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
}
