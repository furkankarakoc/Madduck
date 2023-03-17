//
//  ServiceError.swift
//  Madduck
//
//  Created by Furkan on 16.03.2023.
//

import Foundation

// MARK: - ServiceError
enum ServiceError: Error {
    case unexpectedResponse
    case expectedDataInResponse
    case invalidRequestData
}

enum NetworkError: Error {
    case noInternet
    case apiFailure
    case invalidResponse
    case decodingError
}

extension NetworkError: LocalizedError {
     var errorDescription: String? {
         switch self {
         case .noInternet:
             return NSLocalizedString("No Internet Connection.", comment: "")
         case .apiFailure:
             return NSLocalizedString("The requested resource could not be found but may be available in the future.", comment: "")
         case .invalidResponse:
             return NSLocalizedString("The server was acting as a gateway or proxy and received an invalid response from the upstream server.", comment: "")

         case .decodingError:
             return NSLocalizedString("JSON serialization error.", comment: "")

         }
    }

    var recoverySuggestion: String? {
         return "Please try a different recipe."
    }

}
