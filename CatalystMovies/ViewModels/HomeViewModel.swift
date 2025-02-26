//
//  HomeViewModel.swift
//  CatalystMovies
//
//  Created by Mac on 26/02/25.
//

import Foundation

class HomeViewModel {
    var nowPlayingMovies: [Movie] = []
    var popularMovies: [Movie] = []
    var topRatedMovies: [Movie] = []
    var upcomingMovies: [Movie] = []
    
    var onDataUpdated: (() -> Void)?
    var onError: ((String) -> Void)?
    
    func fetchMovies(for category: MovieCategory) {
        let apiKey = "154ad8f9017ced85e1b45f006f50d4a0"  // Replace with your actual API key
        var urlString = ""
        
        switch category {
        case .nowPlaying:
            urlString = "https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)&language=en-US&page=1"
        case .popular:
            urlString = "https://api.themoviedb.org/3/movie/popular?api_key=\(apiKey)&language=en-US&page=1"
        case .topRated:
            urlString = "https://api.themoviedb.org/3/movie/top_rated?api_key=\(apiKey)&language=en-US&page=1"
        case .upcoming:
            urlString = "https://api.themoviedb.org/3/movie/upcoming?api_key=\(apiKey)&language=en-US&page=1"
        case .trending:  // ✅ New Case Added
            urlString = "https://api.themoviedb.org/3/trending/movie/day?api_key=\(apiKey)&language=en-US"
        }
        
        print("Fetching movies from URL: \(urlString)")  // Debugging log
        
        guard let url = URL(string: urlString) else {
            onError?("Invalid URL: \(urlString)")
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            if let error = error {
                self?.onError?("Network Error: \(error.localizedDescription)")
                return
            }
            guard let data = data else {
                self?.onError?("No data received")
                return
            }
            
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Raw JSON Response: \(jsonString)")  // ✅ Debugging Response
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode(MovieResponse.self, from: data)
                DispatchQueue.main.async {
                    switch category {
                    case .nowPlaying:
                        self?.nowPlayingMovies = decodedResponse.results
                    case .popular:
                        self?.popularMovies = decodedResponse.results
                    case .topRated:
                        self?.topRatedMovies = decodedResponse.results
                    case .upcoming:
                        self?.upcomingMovies = decodedResponse.results
                    case .trending:
                        self?.nowPlayingMovies = decodedResponse.results // ✅ Store Trending Movies in the Now Playing section or create a new variable
                    }
                    self?.onDataUpdated?()
                }
            } catch {
                self?.onError?("Decoding Error: \(error.localizedDescription)")
            }
        }.resume()
    }
}

