//
//  Sources.swift
//  feather
//
//  Created by samara on 5/18/24.
//  Copyright (c) 2024 Samara M (khcrysalis)
//

import Foundation

class SourceGET {
	func downloadURL(from url: URL, completion: @escaping (Result<(Data, HTTPURLResponse?), Error>) -> Void) {
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
					Debug.shared.log(message: "HTTP Error Response: \(responseBody)")
				}
				return
			}
			
			guard let data = data else {
				completion(.failure(NSError(domain: "DataError", code: -1, userInfo: nil)))
				return
			}
			
			completion(.success((data, httpResponse)))
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
			Debug.shared.log(message: "Failed to parse JSON: \(error)", type: .error)
			return .failure(error)
		}
	}
	
	func parseCert(data: Data) -> Result<ServerPack, Error> {
		do {
			let decoder = JSONDecoder()
			decoder.dateDecodingStrategy = .iso8601
			let source = try decoder.decode(ServerPack.self, from: data)
			return .success(source)
		} catch {
			Debug.shared.log(message: "Failed to parse JSON: \(error)", type: .error)
			return .failure(error)
		}
	}
	
	func parsec(data: Data) -> Result<[CreditsPerson], Error> {
		do {
			let decoder = JSONDecoder()
			decoder.dateDecodingStrategy = .iso8601
			let source = try decoder.decode([CreditsPerson].self, from: data)
			return .success(source)
		} catch {
			Debug.shared.log(message: "Failed to parse JSON: \(error)", type: .error)
			return .failure(error)
		}
	}
}
