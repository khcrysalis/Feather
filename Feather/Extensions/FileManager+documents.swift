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
}
