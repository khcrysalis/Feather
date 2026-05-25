//
//  AppStoreHelper.swift
//  Feather
//
//  Created by İsmail Carlık on 25.05.2026.
//


import SwiftUI

struct AppStoreHelper {

	private struct LookupResponse: Codable {
		let results: [AppInfo]
	}

	private struct AppInfo: Codable {
		let trackViewUrl: String
	}

	static func getURL(for bundleID: String) async -> URL? {

		let urlString = "https://itunes.apple.com/lookup?bundleId=\(bundleID)"

		guard let url = URL(string: urlString) else { return nil }

		do {
			let (data, _) = try await URLSession.shared.data(from: url)
			let decoded = try JSONDecoder().decode(
				LookupResponse.self,
				from: data
			)

			if let linkString = decoded.results.first?.trackViewUrl {
				return URL(string: linkString)
			}
		} catch {
			print("AppStoreHelper Error: \(error.localizedDescription)")
		}

		return nil
	}
}
