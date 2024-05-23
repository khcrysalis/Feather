//
//  Sources.swift
//  feather
//
//  Created by samara on 5/18/24.
//

import Foundation
import UIKit

// MARK: - Download
class RepoManager {
	// Download
	func downloadJSON(from url: URL, completion: @escaping (Result<Data, Error>) -> Void) {
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
	// parse
	func parseJSON(data: Data, for identifier: String) -> Result<Source, Error> {
		do {
			let decoder = JSONDecoder()
			decoder.dateDecodingStrategy = .iso8601
			let source = try decoder.decode(Source.self, from: data)
			return .success(source)
		} catch {
			print("Failed to parse JSON for identifier: \(identifier). Error: \(error)\n")
			return .failure(error)
		}
	}
	// Save Source
	func saveJSON(data: Data, identifier: String) throws {
		let fileManager = FileManager.default
		let documentsURL = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
		let sourceDirectoryURL = documentsURL.appendingPathComponent("Sources").appendingPathComponent(identifier)

		try fileManager.createDirectory(at: sourceDirectoryURL, withIntermediateDirectories: true, attributes: nil)

		let fileURL = sourceDirectoryURL.appendingPathComponent("app.json")
		try data.write(to: fileURL)
	}
	// Save URL
	func saveURL(url: URL, identifier: String) throws {
		let source = SourceURL(sourceURL: url)
		let encoder = JSONEncoder()
		encoder.outputFormatting = .prettyPrinted
		
		let jsonData = try encoder.encode(source)
		
		guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
			throw NSError(domain: "FileSystemError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Document directory not found."])
		}
		
		let directoryURL = documentDirectory.appendingPathComponent("Sources").appendingPathComponent(identifier)
		
		do {
			let fileURL = directoryURL.appendingPathComponent("source.json")
			try jsonData.write(to: fileURL, options: .atomic)
			print("Source URL saved to: \(fileURL)")
		} catch {
			throw error
		}
	}
}
// MARK: - List local sources
extension RepoManager {
	func listLocalSources() -> [Source] {
		var sources = [Source]()
		let fileManager = FileManager.default
		do {
			let documentsURL = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
			let sourcesDirectoryURL = documentsURL.appendingPathComponent("Sources")
			let directories = try fileManager.contentsOfDirectory(at: sourcesDirectoryURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
			
			for directory in directories {
				let jsonURL = directory.appendingPathComponent("app.json")
				if let data = try? Data(contentsOf: jsonURL) {
					let decoder = JSONDecoder()
					decoder.dateDecodingStrategy = .iso8601
					if let source = try? decoder.decode(Source.self, from: data) {
						sources.append(source)
					}
				}
			}
		} catch {
			print("Error fetching sources: \(error)\n")
		}
		sources.sort {$0.name! < $1.name!}
		return sources
	}
	
	func fetchLocalURL(for source: Source) -> URL? {
		let fileManager = FileManager.default
		let documentsURL = try? fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
		let sourceJSONPath = documentsURL?.appendingPathComponent("Sources").appendingPathComponent(source.identifier).appendingPathComponent("source.json").path
		
		guard let sourceJSONPath = sourceJSONPath else {
			return nil
		}
		
		let jsonData = fileManager.contents(atPath: sourceJSONPath)!
		do {
			let source = try JSONDecoder().decode(SourceURL.self, from: jsonData)
			return source.sourceURL
		} catch {
			print("Error decoding JSON: \(error)")
			return nil
		}

	}
}
// MARK: - Add/fetch sources
extension RepoManager {
	// Remove Sources
	func deleteSource(with identifier: String) {
		let fileManager = FileManager.default
		do {
			let documentsURL = try! fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
			let sourceDirectoryURL = documentsURL.appendingPathComponent("Sources").appendingPathComponent(identifier)
			
			if fileManager.fileExists(atPath: sourceDirectoryURL.path) {
				try fileManager.removeItem(at: sourceDirectoryURL)
			} else {
				print("Directory does not exist: \(sourceDirectoryURL.path)")
			}
			
		} catch {
			print("Error deleting source directory: \(error.localizedDescription)")
		}
	}
	// Add Sources
	func addSource(from urlString: String) {
		guard let url = URL(string: urlString) else { return }

		self.downloadJSON(from: url) { result in
			switch result {
			case .success(let data):
				let parseResult = self.parseJSON(data: data, for: urlString)
				switch parseResult {
				case .success(let source):
					do {
						try! self.saveJSON(data: data, identifier: source.identifier)
						try! self.saveURL(url: url, identifier: source.identifier)
					}
				case .failure(let error): print("Failed to parse JSON: \(error)\n")
				}
			case .failure(_): break
			}
		}
	}
	// Refresh Sources
	func refreshSources(sources: [Source], group: DispatchGroup) {
		for source in sources {
			let sourceURL = URL(string: RepoManager().fetchLocalURL(for: source)!.absoluteString)!
			
			group.enter()
			RepoManager().downloadJSON(from: sourceURL) { result in
				switch result {
				case .success(let data):
					let parseResult = RepoManager().parseJSON(data: data, for: source.identifier)
					switch parseResult {
					case .success(let newSource):
						do {
							try! RepoManager().saveJSON(data: data, identifier: newSource.identifier)
						}
					case .failure(let error): print("Failed to parse JSON: \(error)\n")
					}
				case .failure(_): break
				}
				group.leave()
			}
		}
	}
	
}
