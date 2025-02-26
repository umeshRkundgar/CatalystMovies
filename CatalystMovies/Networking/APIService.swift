//
//  APIService.swift
//  CatalystMovies
//
//  Created by Mac on 26/02/25.
//

import Foundation

class APIService {
    static let shared = APIService()
    private let baseURL = "https://api.themoviedb.org/3"
    private let apiKey = "154ad8f9017ced85e1b45f006f50d4a0"
    
    func fetchMovies(endpoint: String, completion: @escaping (Result<[Movie], Error>) -> Void) {
        let urlString = "\(baseURL)/\(endpoint)?api_key=\(apiKey)"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 400, userInfo: nil)))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No Data", code: 404, userInfo: nil)))
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
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
}
