//
//  PokemonsAPIProvider.swift
//  PokemonsAPI
//
//  Created by Kristina Marchenko on 28.07.2021.
//

import Foundation
import Alamofire

protocol PokemonsAPIProvider {
    func getResponseHandler<T>(
        completion: @escaping (Result<T, NetworkError>) -> Void
    ) -> ((AFDataResponse<T>) -> Void)
}

extension PokemonsAPIProvider {
    func getResponseHandler<T>(
        completion: @escaping (Result<T, NetworkError>) -> Void
    ) -> ((AFDataResponse<T>) -> Void) {
        { (response: AFDataResponse<T>) in
            let mapped = response.result.mapError {
                Self.mapError(error: $0, response: response)
            }
            completion(mapped)
        }
    }
}

private extension PokemonsAPIProvider {
    private static func mapError<T>(error: AFError, response: AFDataResponse<T>) -> NetworkError {
        if error.isNetworkConnectionError {
            return .connectionError(error)
        } else if let code = response.response?.statusCode {
            return .generic(GenericNetworkError(
                code: code,
                errorDescription: error.errorDescription,
                underlying: error.underlyingError
            ))
        } else {
            return .other(error)
        }
    }
}

// MARK: - AFError+isNetworkConnectionError

private extension AFError {
    var isNetworkConnectionError: Bool {
        var err = self
        
        for _ in 0..<5 {
            if let underlyingError = err.underlyingError {
                if (underlyingError as NSError).domain == NSURLErrorDomain {
                    return true
                } else if let underlyingAsAFError = underlyingError.asAFError {
                    err = underlyingAsAFError
                } else {
                    return false
                }
            } else {
                return false
            }
        }
        return false
    }
}
