//
//  DownloadCertificate.swift
//  feather
//
//  Created by samara on 8/18/24.
//

import Foundation

func getCertificates() {
	let sourceGET = SourceGET()
	let dispatchGroup = DispatchGroup()
	let uri = URL(string: "https://backloop.dev/pack.json")!
	
	func writeToFile(content: String, filename: String) throws {
		let path = getDocumentsDirectory().appendingPathComponent(filename)
		try content.write(to: path, atomically: true, encoding: .utf8)
	}
	
	dispatchGroup.enter()
	
	defer {
		dispatchGroup.leave()
	}
	
	sourceGET.downloadURL(from: uri) { result in
		switch result {
		case .success(let (data, _)):
			switch sourceGET.parseCert(data: data) {
			case .success(let serverPack):
				do {
					try writeToFile(content: serverPack.key, filename: "server.pem")
					try writeToFile(content: serverPack.cert, filename: "server.crt")
					try writeToFile(content: serverPack.info.domains.commonName, filename: "commonName.txt")
				} catch {
					Debug.shared.log(message: "Error writing files: \(error.localizedDescription)")
				}
			case .failure(let error):
				Debug.shared.log(message: "Error parsing certificate: \(error.localizedDescription)")
			}
		case .failure(let error):
			Debug.shared.log(message: "Error fetching data from \(uri): \(error.localizedDescription)")
		}
	}
}

func getDocumentsDirectory() -> URL {
	let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
	let documentsDirectory = paths[0]
	return documentsDirectory
}

