//
//  DownloadCertificate.swift
//  feather
//
//  Created by samara on 8/18/24.
//

import Foundation

func downloadCertificatesOnline(from urlStrings: [String], completion: @escaping (Result<[URL], Error>) -> Void) {
	var downloadedURLs: [URL] = []
	let dispatchGroup = DispatchGroup()

	for urlString in urlStrings {
		guard let url = URL(string: urlString) else {
			Debug.shared.log(message: "Invalid URL: \(urlString).")
			completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
			return
		}

		let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
		let destinationURL = documentsDirectory.appendingPathComponent(url.lastPathComponent)

		dispatchGroup.enter()
		Debug.shared.log(message: "Downloading file from \(url)")
		let task = URLSession.shared.downloadTask(with: url) { tempLocalURL, response, error in
			defer { dispatchGroup.leave() }

			if let error = error {
				completion(.failure(error))
				return
			}

			guard let tempLocalURL = tempLocalURL else {
				Debug.shared.log(message: "Failed to download file from \(urlString).")
				completion(.failure(NSError(domain: "Download failed", code: -1, userInfo: nil)))
				return
			}

			do {
				if FileManager.default.fileExists(atPath: destinationURL.path) {
					try FileManager.default.removeItem(at: destinationURL)
				}

				try FileManager.default.moveItem(at: tempLocalURL, to: destinationURL)
				downloadedURLs.append(destinationURL)
			} catch {
				completion(.failure(error))
				return
			}
		}

		task.resume()
	}

	dispatchGroup.notify(queue: .main) {
		if downloadedURLs.count == urlStrings.count {
			completion(.success(downloadedURLs))
		} else {
			completion(.failure(NSError(domain: "Some downloads failed", code: -1, userInfo: nil)))
		}
	}
}

func getDocumentsDirectory() -> URL {
	let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
	let documentsDirectory = paths[0]
	return documentsDirectory
}

