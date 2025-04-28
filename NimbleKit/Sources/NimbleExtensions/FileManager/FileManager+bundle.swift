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
}
