//
//  HomeViewModel.swift
//  CatalystMovies
//
//  Created by Mac on 26/02/25.
//

import Foundation

class HomeViewModel {
    var trendingMovies: [Movie] = []
    var nowPlayingMovies: [Movie] = []
    var popularMovies: [Movie] = []
    var topRatedMovies: [Movie] = []
    var upcomingMovies: [Movie] = []
    var onTrendingUpdated: (() -> Void)? //Notify when trending updates
    var onDataUpdated: (() -> Void)?
    var onError: ((String) -> Void)?
    
    
    //var baseURL = "https://api.themoviedb.org/3"
    func fetchMovies(for category: MovieCategory) {
        let apiKey = "154ad8f9017ced85e1b45f006f50d4a0"
        let urlString: String
        switch category {
        case .trending:
            urlString = "https://api.themoviedb.org/3/trending/movie/day?api_key=\(apiKey)&language=en-US"
        case .nowPlaying:
            urlString = "https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)&language=en-US&page=1"
        case .popular:
            urlString = "https://api.themoviedb.org/3/movie/popular?api_key=\(apiKey)&language=en-US&page=1"
        case .topRated:
            urlString = "https://api.themoviedb.org/3/movie/top_rated?api_key=\(apiKey)&language=en-US&page=1"
        case .upcoming:
            urlString = "https://api.themoviedb.org/3/movie/upcoming?api_key=\(apiKey)&language=en-US&page=1"
        
        }
        
        print("Fetching movies from URL: \(urlString)")
        
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
                print("Raw JSON Response: \(jsonString)")
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode(MovieResponse.self, from: data)
                DispatchQueue.main.async {
                    switch category {
                    case .trending:
                        self?.trendingMovies = decodedResponse.results
                        self?.onTrendingUpdated?()//Notify only trending
                    case .nowPlaying:
                        self?.nowPlayingMovies = decodedResponse.results
                    case .popular:
                        self?.popularMovies = decodedResponse.results
                    case .topRated:
                        self?.topRatedMovies = decodedResponse.results
                    case .upcoming:
                        self?.upcomingMovies = decodedResponse.results
                    
                    }
                    self?.onDataUpdated?()
                }
            } catch {
                self?.onError?("Decoding Error: \(error.localizedDescription)")
            }
        }.resume()
    }
}

