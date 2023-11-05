//
//  RMEpisode.swift
//  RickAndMorty
//
//  Created by Olexandr Kostenko on 05.11.2023.
//

import Foundation

struct RMEpisode: Codable {
    let id: Int
    let name: String
    let air_date: String
    let episode: String
    let charachters: [String]
    let url: String
    let created: String
}
