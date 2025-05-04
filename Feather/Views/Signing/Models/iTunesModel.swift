//
//  iTunesLookupResult.swift
//  Feather
//
//  Created by samara on 3.05.2025.
//

struct iTunesModel: Codable {
    let resultCount: Int
    let results: [iTunesResultModel]
}

struct iTunesResultModel: Codable {
    let bundleId: String
}
