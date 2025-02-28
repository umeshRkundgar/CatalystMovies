//
//  TrailerResponse.swift
//  CatalystMovies
//
//  Created by Mac on 28/02/25.
//

import Foundation

struct TrailerResponse: Codable {
    let results: [Trailer]
}

struct Trailer: Codable {
    let key: String
    let site: String
}

