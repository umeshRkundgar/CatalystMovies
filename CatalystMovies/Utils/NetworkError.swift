//
//  NetworkError.swift
//  CatalystMovies
//
//  Created by Mac on 26/02/25.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case noInternet
    case requestFailed
    case decodingFailed
    case unauthorized
    case serverError(statusCode: Int)
    case unknown(Error)
    case notFound

    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "The URL provided was invalid."
        case .noInternet:
            return "No internet connection. Please check your network."
        case .requestFailed:
            return "Failed to fetch data. Please try again."
        case .decodingFailed:
            return "Failed to decode the response."
        case .unauthorized:
            return "Unauthorized request. Please check your credentials."
        case .serverError(let statusCode):
            return "Server error occurred. Status Code: \(statusCode)"
        case .unknown(let error):
            return "An unknown error occurred: \(error.localizedDescription)"
        case .notFound:
            return "No YouTube Trailer Found"
        }
    }
}

