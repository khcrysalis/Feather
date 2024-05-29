//
//  Sources.swift
//  feather
//
//  Created by samara on 5/18/24.
//

import Foundation
import UIKit

class RepoManager {
	func downloadURL(from url: URL, completion: @escaping (Result<Data, Error>) -> Void) {
		let task = URLSession.shared.dataTask(with: url) { data, response, error in
			if let error = error {
				completion(.failure(error))
				return
			}
			
			guard let httpResponse = response as? HTTPURLResponse else {
				completion(.failure(NSError(domain: "InvalidResponse", code: -1, userInfo: nil)))
				return
			}
			
			guard (200...299).contains(httpResponse.statusCode) else {
				let errorDescription = HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode)
				completion(.failure(NSError(domain: "HTTPError", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorDescription])))
				if let data = data, let responseBody = String(data: data, encoding: .utf8) {
					print("HTTP Error Response: \(responseBody)")
				}
				return
			}
			
			guard let data = data else {
				completion(.failure(NSError(domain: "DataError", code: -1, userInfo: nil)))
				return
			}
			
			completion(.success(data))
		}
		task.resume()
	}
	
	func parse(data: Data) -> Result<SourcesData, Error> {
		do {
			let decoder = JSONDecoder()
			decoder.dateDecodingStrategy = .iso8601
			let source = try decoder.decode(SourcesData.self, from: data)
			return .success(source)
		} catch {
			print("Failed to parse JSON for identifier: Error: \(error)\n")
			return .failure(error)
		}
	}
	
}
