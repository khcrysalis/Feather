//
//  FileManager+bundle.swift
//  Feather
//
//  Created by samara on 16.04.2025.
//

import Foundation.NSFileManager

extension FileManager {
	func appBundle(in directory: URL) -> URL? {
		guard let contents = try? contentsOfDirectory(at: directory, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles]) else {
			return nil
		}
		
		return contents.first(where: { $0.pathExtension == "app" })
	}
	
	func provisionFile(in directory: URL) -> URL? {
		let file = directory.appendingPathComponent("embedded.mobileprovision")
		
		if self.fileExists(atPath: file.path()) {
			return file
		} else {
			return nil
		}
	}
}
