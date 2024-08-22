//
//  DownloadCertificate.swift
//  feather
//
//  Created by samara on 8/18/24.
//

import Foundation

func downloadCertificateOnline(from urlString: String, completion: @escaping (Result<URL, Error>) -> Void) {
	guard let url = URL(string: urlString) else {
		print("Invalid URL.")
		return
	}

	let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
	let destinationURL = documentsDirectory.appendingPathComponent("localhost.direct.pfx")

	let task = URLSession.shared.downloadTask(with: url) { tempLocalURL, response, error in
		if let error = error {
			completion(.failure(error))
			return
		}

		guard let tempLocalURL = tempLocalURL else {
			Debug.shared.log(message: "Failed to download file.")
			return
		}

		do {
			if FileManager.default.fileExists(atPath: destinationURL.path) {
				try FileManager.default.removeItem(at: destinationURL)
			}

			try FileManager.default.moveItem(at: tempLocalURL, to: destinationURL)
			completion(.success(destinationURL))
		} catch {
			completion(.failure(error))
		}
	}

	task.resume()
}

func getPFXFilePath() -> URL? {
	let pfxFileURL = getDocumentsDirectory().appendingPathComponent("localhost.direct.pfx")

	if FileManager.default.fileExists(atPath: pfxFileURL.path) {
		return pfxFileURL
	} else {
		return Bundle.main.url(forResource: "localhost.direct", withExtension: "pfx")
	}
}
