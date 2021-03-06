//
//  PokemonService.swift
//  Pokemons
//
//  Created by Kristina Marchenko on 27.07.2021.
//

import Foundation
import PokemonsAPI

final class PokemonService {
    private(set) var favoritePokemons: [Pokemon]?
    private(set) var nonFavoritePokemons: [Pokemon]?
    var allPokemons: [Pokemon] {
        (favoritePokemons ?? []) + (nonFavoritePokemons ?? [])
    }
    
    var areAllPokemonsDownloaded: Bool {
        if let nonFavorite = nonFavoritePokemons?.count, let favorite = favoritePokemons?.count {
            return allPossiblePokemonCount == nonFavorite + favorite
        } else {
            return false
        }
    }
    var pokemonBatchLimit = AppConstants.defaultPokemonPageSize
    
    typealias Storage = StoresFavoritePokemonsNames
    private let storage: Storage
    private let pokemonProvider: PokemonProviderType
    
    private var allPossiblePokemonCount: Int?
    private var offset = 0
    private var isPokemonBatchDownloadInProgress = false
    
    // Utilities for pokemon download optimization
    private var favoritesFetcher: PokemonFetcher?
    private var nonFavoritesFetcher: NonFavoritePokemonBatchFetcher?
    
    init(pokemonProvider: PokemonProviderType, storage: Storage) {
        self.pokemonProvider = pokemonProvider
        self.storage = storage
    }
}

// MARK: - PokemonServiceType

extension PokemonService: PokemonServiceType {
    func loadFavoritePokemons(completion: @escaping (Result<[Pokemon], PokemonServiceError>) -> Void) {
        let completion: (Result<[Pokemon], NetworkError>) -> Void = { [weak self] result in
            guard let self = self else { return }
            if case let .success(pokemons) = result {
                self.favoritesFetcher = nil
                self.favoritePokemons = pokemons.sorted(by: self.arePokemonsInIncreasingOrder)
            }
            completion(result.mapError(Self.map(networkError:)))
        }
        
        if let fetcher = favoritesFetcher {
            fetcher.fetch(completion: completion)
        } else {
            let names = storage.favoritePokemonsNames
            if names.isEmpty {
                completion(.success([]))
            } else {
                let fetcher = PokemonFetcher(pokemonProvider: pokemonProvider, namesToFetch: names)
                favoritesFetcher = fetcher
                fetcher.fetch(completion: completion)
            }
        }
    }
    
    func loadNextPokemonBatchIfNotAlready(
        completion: @escaping (Result<[Pokemon], PokemonServiceError>) -> Void
    ) {
        guard !isPokemonBatchDownloadInProgress else { return }
        isPokemonBatchDownloadInProgress = true
        
        let completion: (Result<PokemonBatchFetchResult, NetworkError>) -> Void = { [weak self] result in
            guard let self = self else { return }
            self.isPokemonBatchDownloadInProgress = false
            let mapped = result
                .map { fetchResult -> [Pokemon] in
                    if self.nonFavoritePokemons == nil {
                        self.nonFavoritePokemons = []
                    }
                    self.allPossiblePokemonCount = fetchResult.allPossiblePokemonCount
                    let sorted = fetchResult.pokemons.sorted(by: self.arePokemonsInIncreasingOrder)
                    self.nonFavoritePokemons?.append(contentsOf: sorted)
                    self.offset = fetchResult.resultOffset
                    self.nonFavoritesFetcher = nil
                    
                    return sorted
                }
                .mapError(Self.map(networkError:))
            completion(mapped)
        }
        
        if let fetcher = nonFavoritesFetcher {
            fetcher.fetchNext(completion: completion)
        } else {
            let fetcher = NonFavoritePokemonBatchFetcher(
                pokemonProvider: pokemonProvider,
                initialOffset: offset,
                limit: pokemonBatchLimit,
                namesToIgnore: favoritePokemons.map { $0.map { $0.name } } ?? storage.favoritePokemonsNames
            )
            nonFavoritesFetcher = fetcher
            fetcher.fetchNext(completion: completion)
        }
    }
    
    func addToFavoritesPokemonWithId(_ id: Int) {
        guard let indexToRemove = nonFavoritePokemons?.firstIndex(where: { $0.id == id }),
              let pokemon = nonFavoritePokemons?.remove(at: indexToRemove)
        else { return }
        
        let index = favoritePokemons?
            .lastIndex(where: predicateForLastIndexToInsertPokemonAfter(pokemon: pokemon))
            .map { favoritePokemons?.index(after: $0) }
            ?? favoritePokemons?.startIndex
        index.map { favoritePokemons?.insert(pokemon, at: $0) }
        storage.saveFavoritePokemonName(pokemon.name)
    }
    
    func removeFromFavoritesPokemonWithId(_ id: Int) {
        guard let indexToRemove = favoritePokemons?.firstIndex(where: { $0.id == id }),
              let pokemon = favoritePokemons?.remove(at: indexToRemove)
        else { return }
        storage.removeFavoritePokemonName(pokemon.name)
        
        if let indexToInsertAfter = nonFavoritePokemons?.lastIndex(where: {
            $0.order < pokemon.order || $0.order == pokemon.order && $0.name < pokemon.name
        }) {
            if let indexToInsert = nonFavoritePokemons?.index(after: indexToInsertAfter),
               indexToInsert != nonFavoritePokemons?.endIndex {
                nonFavoritePokemons?.insert(pokemon, at: indexToInsert)
            } else {
                nonFavoritesFetcher?.markPokemonAsIncluded(pokemon)
            }
        } else {
            nonFavoritePokemons?.insert(pokemon, at: 0)
        }
    }
}

// MARK: - Decomposition

private extension PokemonService {
    var arePokemonsInIncreasingOrder: (Pokemon, Pokemon) -> Bool {
        { $0.order != $1.order ? $0.order < $1.order : $0.name < $1.name }
    }
    
    func predicateForLastIndexToInsertPokemonAfter(pokemon: Pokemon) -> ((Pokemon) -> Bool) {
        { $0.order < pokemon.order || $0.order == pokemon.order && $0.name < pokemon.name }
    }
}

// MARK: - Error Mapping

private extension PokemonService {
    static func map(networkError: NetworkError) -> PokemonServiceError {
        let description: String
        switch networkError {
        case let .connectionError(error):
            description = error.localizedDescription
        case .generic, .other:
            description = L10n.PokemonFetch.Error.unknown
        }
        
        return .networkError(description)
    }
}
