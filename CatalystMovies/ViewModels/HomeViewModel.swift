//
//  HomeViewModel.swift
//  CatalystMovies
//
//  Created by Mac on 26/02/25.
//

import Foundation

class HomeViewModel {
    // MARK: - Movie Categories
    
    var trendingMovies: [Movie] = []
    var nowPlayingMovies: [Movie] = []
    var popularMovies: [Movie] = []
    var topRatedMovies: [Movie] = []
    var upcomingMovies: [Movie] = []
    
    // MARK: - Data Binding Callbacks
    var isLoading: ((Bool) -> Void)?
    var onTrendingUpdated: (() -> Void)?
    var onDataUpdated: (() -> Void)?
    var onError: ((String) -> Void)?
    
    
    // MARK: - API Calls
    func fetchMovies(for category: MovieCategory) {
        isLoading?(true)//start loading
        print("Fetching started...")
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
            isLoading?(false)
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            //            defer {
            //                DispatchQueue.main.async {
            //                    self?.isLoading?(false)
            //                }
            //            }
            if let error = error {
                self?.onError?("Network Error: \(error.localizedDescription)")
                self?.isLoading?(false)
                return
            }
            guard let data = data else {
                DispatchQueue.main.async {
                    print("No data received")
                    self?.onError?("No data received")
                    self?.isLoading?(false) // Hide indicator
                }
                return
            }
            
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Raw JSON Response: \(jsonString)")
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode(MovieResponse.self, from: data)
                DispatchQueue.main.async {
                    print("Movies Decoded updating UI.")
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
                    self?.isLoading?(false)
                }
            } catch {
                self?.onError?("Decoding Error: \(error.localizedDescription)")
                self?.isLoading?(false)
            }
        }.resume()
    }
}

