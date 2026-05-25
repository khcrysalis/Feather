//
//  AppStoreHelper.swift
//  Feather
//
//  Created by İsmail Carlık on 25.05.2026.
//

import Foundation

struct AppStoreHelper {

	private struct LookupResponse: Codable {
		let results: [AppInfo]
	}

	private struct AppInfo: Codable {
		let trackViewUrl: String
	}

	static func getURL(for bundleID: String) async -> URL? {

		var components = URLComponents(
			string: "https://itunes.apple.com/lookup"
		)
		
		components?.queryItems = [
			URLQueryItem(name: "bundleId", value: bundleID)
		]

		guard let url = components?.url else { return nil }

		do {
			let (data, response) = try await URLSession.shared.data(from: url)
			
			guard let httpResponse = response as? HTTPURLResponse,
				  httpResponse.statusCode == 200 else {
				print("AppStoreHelper Error: Invalid response")
				return nil
			}
			
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
