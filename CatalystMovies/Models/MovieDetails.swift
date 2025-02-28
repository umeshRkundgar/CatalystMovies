//
//  MovieDetails.swift
//  CatalystMovies
//
//  Created by Mac on 27/02/25.
//

import Foundation
struct MovieDetails: Codable {
    let runtime: Int?
    let genres: [Genre]
    let overview: String

    enum CodingKeys: String, CodingKey {
        case runtime, genres, overview
    }
}

struct Genre: Codable {
    let id: Int
    let name: String
}
