//
//  Movie.swift
//  CatalystMovies
//
//  Created by Mac on 26/02/25.
//

import Foundation



struct Movie: Codable {
    let id: Int
    let title: String
    let posterPath: String?
    let backdropPath: String?
    let releaseDate: String
    enum CodingKeys: String, CodingKey {
        case id, title
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case releaseDate = "release_date"
    }
    
    var posterURL: URL? {
        guard let path = posterPath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w500\(path)")
    }
    var backdropURL: URL? {
        guard let path = backdropPath else{return nil}
        return URL(string: "https://image.tmdb.org/t/p/w500\(path)")
    }
}
