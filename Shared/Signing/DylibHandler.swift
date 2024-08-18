//
//  DylibHandler.swift
//  feather
//
//  Created by samara on 8/17/24.
//

import Foundation

class DylibHandler {
	static func getInitialFiles(urls: [URL], app: URL) throws {
		guard !urls.isEmpty else {
			Debug.shared.log(message: "No dylibs to inject, skipping!")
			return
		}
		Debug.shared.log(message: "Attempting to inject...")
		Debug.shared.log(message: "Files to inject: \(urls)")
		Debug.shared.log(message: "App to inject into: \(app)")
		
		let fileManager = FileManager.default
		let tmpDir = fileManager.temporaryDirectory.appendingPathComponent(UUID().uuidString)
		
		try fileManager.createDirectory(at: tmpDir, withIntermediateDirectories: true, attributes: nil)
		
		for url in urls {
			Debug.shared.log(message: "Extracting file: \(url)")
		
		}
		
		Debug.shared.log(message: "Extraction complete. Files located at: \(tmpDir.path)")
	}
}

class DebExtractor {
	
}
