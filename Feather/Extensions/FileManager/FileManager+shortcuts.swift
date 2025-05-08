//
//  FileManager+shortcuts.swift
//  Feather
//
//  Created by samara on 8.05.2025.
//

import Foundation.NSFileManager

extension FileManager {
	func removeFileIfNeeded(at url: URL) throws {
		if self.fileExists(atPath: url.path) {
			try self.removeItem(at: url)
		}
	}
	
	func moveFileIfNeeded(from sourceURL: URL, to destinationURL: URL) throws {
		if !self.fileExists(atPath: destinationURL.path) {
			try self.moveItem(at: sourceURL, to: destinationURL)
		}
	}
	
	func createDirectoryIfNeeded(at url: URL) throws {
		if !self.fileExists(atPath: url.path) {
			try self.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
		}
	}
	
	// FeatherTweak
	func moveAndStore(_ url: URL, with prepend: String, completion: @escaping (URL) -> Void) {
		let destination = _getDestination(url, with: prepend)
		
		try? createDirectoryIfNeeded(at: destination.temp)
		
		try? self.copyItem(at: url, to: destination.dest)
		completion(destination.dest)
	}
	
	func deleteStored(_ url: URL, completion: @escaping (URL) -> Void) {
		try? FileManager.default.removeItem(at: url)
		completion(url)
	}
	
	// FeatherTweak
	private func _getDestination(_ url: URL, with prepend: String) -> (temp: URL, dest: URL) {
		let tempDir = self.temporaryDirectory.appendingPathComponent("\(prepend)_\(UUID().uuidString)", isDirectory: true)
		let destinationUrl = tempDir.appendingPathComponent(url.lastPathComponent)
		return (tempDir, destinationUrl)
	}
}
