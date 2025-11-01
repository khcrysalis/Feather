//
//  URL+SHA256.swift
//  Feather
//
//  Created by AI Assistant
//

import Foundation
import CryptoKit

extension URL {
	/// Calculate SHA256 hash of the file at this URL
	/// - Returns: Hex string of the hash, or nil if calculation fails
	func sha256Hash() -> String? {
		guard let fileHandle = try? FileHandle(forReadingFrom: self) else {
			return nil
		}
		
		defer {
			try? fileHandle.close()
		}
		
		var hasher = SHA256()
		let bufferSize = 1024 * 1024 // 1MB buffer
		
		while autoreleasepool(invoking: {
			let data = fileHandle.readData(ofLength: bufferSize)
			if data.isEmpty {
				return false // End of file
			}
			hasher.update(data: data)
			return true
		}) {}
		
		let hash = hasher.finalize()
		return hash.compactMap { String(format: "%02x", $0) }.joined()
	}
}

