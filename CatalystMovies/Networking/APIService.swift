//
//  APIService.swift
//  CatalystMovies
//
//  Created by Mac on 26/02/25.
//

import Foundation

class APIService {
    
    static let shared = APIService()
    
    //MARK: - Configuration
    private let baseURL = "https://api.themoviedb.org/3"
    private let apiKey = "154ad8f9017ced85e1b45f006f50d4a0"
    
    //MARK: - Movie Fetching
    func fetchMovies(endpoint: String, completion: @escaping (Result<[Movie], NetworkError>) -> Void) {
        let urlString = "\(baseURL)/\(endpoint)?api_key=\(apiKey)"
        guard let url = URL(string: urlString) else {
            completion(.failure(.invalidURL))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error as? URLError {
                switch error.code{
                case .notConnectedToInternet:
                    completion(.failure(.noInternet))
                default:
                    completion(.failure(.unknown(error)))
                }
                return
            }
            guard let httpResponse = response as? HTTPURLResponse else{
                completion(.failure(.requestFailed))
                return
            }
            guard let data = data else {
                completion(.failure(.requestFailed))
                return
            }
            guard(200...299).contains(httpResponse.statusCode) else{
                completion(.failure(.serverError(statusCode: httpResponse.statusCode)))
                return
            }
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Raw JSON Response: \(jsonString)")
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode(MovieResponse.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(decodedResponse.results))
                }
            } catch {
                completion(.failure(.decodingFailed))
            }
        }
        
        task.resume()
    }
    
    
}
//MARK: -  Movie Details and Casts and Trailers

extension APIService {
    //MARK: - Movie Details
    func fetchMovieDetails(movieID: Int, completion: @escaping (Result<MovieDetails, NetworkError>) -> Void) {
        let urlString = "\(baseURL)/movie/\(movieID)?api_key=\(apiKey)&language=en-US"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(.invalidURL))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error  as? URLError {
                switch error.code{
                case .notConnectedToInternet:
                    completion(.failure(.noInternet))
                default:
                    completion(.failure(.unknown(error)))
                }
                return
            }
            
            guard let data = data else {
                completion(.failure(.requestFailed))
                return
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode(MovieDetails.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(decodedResponse))
                }
            } catch {
                completion(.failure(.decodingFailed))
            }
        }.resume()
    }
    //MARK: - Cast Fetching
    func fetchCast(movieID: Int, completion: @escaping (Result<[Cast], NetworkError>) -> Void) {
        let urlString = "\(baseURL)/movie/\(movieID)/credits?api_key=\(apiKey)"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(.invalidURL))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data,response, error in
            if let error = error  as? URLError {
                switch error.code{
                case .notConnectedToInternet:
                    completion(.failure(.noInternet))
                default:
                    completion(.failure(.unknown(error)))
                }
                return
            }
            guard let httpResponse = response as? HTTPURLResponse else{
                completion(.failure(.requestFailed))
                return
            }
            guard (200...299).contains(httpResponse.statusCode) else{
                completion(.failure(.serverError(statusCode: httpResponse.statusCode)))
                return
            }
            guard let data = data else {
                completion(.failure(.requestFailed))
                return
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode(CastResponse.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(decodedResponse.cast))
                    
                }
            } catch {
                completion(.failure(.decodingFailed))
            }
        }.resume()
    }
    //MARK: - Trailer Fetching
    func fetchTrailer(movieID: Int, completion: @escaping (Result<String, NetworkError>) -> Void) {
        let urlString = "\(baseURL)/movie/\(movieID)/videos?api_key=\(apiKey)"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(.invalidURL))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error  as? URLError {
                switch error.code{
                case .notConnectedToInternet:
                    completion(.failure(.noInternet))
                default:
                    completion(.failure(.unknown(error)))
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else{
                completion(.failure(.requestFailed))
                return
            }
            guard (200...299).contains(httpResponse.statusCode) else{
                completion(.failure(.serverError(statusCode: httpResponse.statusCode)))
                return
            }
            guard let data = data else {
                completion(.failure(.requestFailed))
                return
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode(TrailerResponse.self, from: data)
                if let firstTrailer = decodedResponse.results.first(where: { $0.site.lowercased() == "youtube" }) {
                    let youtubeURL = "https://www.youtube.com/embed/\(firstTrailer.key)"
                    completion(.success(youtubeURL))
                } else {
                    completion(.failure(.notFound))
                }
            } catch {
                completion(.failure(.decodingFailed))
            }
        }.resume()
    }
}
