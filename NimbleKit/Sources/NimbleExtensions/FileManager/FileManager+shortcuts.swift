//
//  FileManager+bundle.swift
//  Feather
//
//  Created by samara on 16.04.2025.
//

import Foundation.NSFileManager

extension FileManager {
	public func getPath(in directory: URL, for pathExtension: String) -> URL? {
		guard let contents = try? contentsOfDirectory(at: directory, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles]) else {
			return nil
		}
		
		return contents.first(where: { $0.pathExtension == pathExtension })
	}
	
	public func isFileFromFileProvider(at url: URL) -> Bool {
		if let resourceValues = try? url.resourceValues(forKeys: [.isUbiquitousItemKey, .fileResourceIdentifierKey]),
		   resourceValues.isUbiquitousItem == true {
			return true
		}
		
		let path = url.path
		if path.contains("/Library/CloudStorage/") || path.contains("/File Provider Storage/") {
			return true
		}
		
		return false
	}
	
	public func removeFileIfNeeded(at url: URL) throws {
		if self.fileExists(atPath: url.path) {
			try self.removeItem(at: url)
		}
	}
	
	public func moveFileIfNeeded(from sourceURL: URL, to destinationURL: URL) throws {
		if !self.fileExists(atPath: destinationURL.path) {
			try self.moveItem(at: sourceURL, to: destinationURL)
		}
	}
	
	public func createDirectoryIfNeeded(at url: URL) throws {
		if !self.fileExists(atPath: url.path) {
			try self.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
		}
	}
	
	static public func forceWrite(content: String, to filename: String) throws {
		let path = URL.documentsDirectory.appendingPathComponent(filename)
		try content.write(to: path, atomically: true, encoding: .utf8)
	}
	
	public func decodeAndWrite(base64: String, pathComponent: String) -> URL? {
		let raw = base64.replacingOccurrences(of: " ", with: "+")
		guard let data = Data(base64Encoded: raw) else { return nil }
		let dir = self.temporaryDirectory.appendingPathComponent(UUID().uuidString + pathComponent)
		try? data.write(to: dir)
		return dir
	}
	
	// FeatherTweak
	public func moveAndStore(_ url: URL, with prepend: String, completion: @escaping (URL) -> Void) {
		let destination = _getDestination(url, with: prepend)
		
		try? createDirectoryIfNeeded(at: destination.temp)
		
		try? self.copyItem(at: url, to: destination.dest)
		completion(destination.dest)
	}
	
	public func deleteStored(_ url: URL, completion: @escaping (URL) -> Void) {
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
