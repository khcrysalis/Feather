//
//  FileManager+documents.swift
//  Feather
//
//  Created by samara on 11.04.2025.
//

import Foundation.NSFileManager

extension FileManager {
	var documentsDirectory: URL {
		guard let url = urls(for: .documentDirectory, in: .userDomainMask).first else {
			fatalError("Unable to locate the documents directory.")
		}
		return url
	}
	
	var signed: URL {
		documentsDirectory.appendingPathComponent("Signed")
	}
	
	func signed(_ uuid: String) -> URL {
		signed.appendingPathComponent(uuid)
	}
	
	var unsigned: URL {
		documentsDirectory.appendingPathComponent("Unsigned")
	}
	
	func unsigned(_ uuid: String) -> URL {
		unsigned.appendingPathComponent(uuid)
	}
	
	func appBundle(in directory: URL) -> URL? {
		guard let contents = try? contentsOfDirectory(at: directory, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles]) else {
			return nil
		}
		
		return contents.first(where: { $0.pathExtension == "app" })
	}
}
