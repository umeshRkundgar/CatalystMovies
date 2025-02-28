//
//  CastMember.swift
//  CatalystMovies
//
//  Created by Mac on 27/02/25.
//

import Foundation
struct CastResponse: Codable {
    let cast: [Cast]
}

struct Cast: Codable {
    let name: String
    let profilePath: String?

    enum CodingKeys: String, CodingKey {
        case name
        case profilePath = "profile_path"
    }

    var profileURL: URL? {
        guard let path = profilePath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w500\(path)")
    }
}
