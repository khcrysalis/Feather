//
//  PathSanitizer.swift
//  Feather
//
//  Created by Jacob Prezant on 1/2/25
//

import Foundation

enum PathSanitizer {
	static func safePathComponent(_ input: String, fallback: String) -> String {
		let sanitized = input
			.replacingOccurrences(of: "..", with: "_")
			.replacingOccurrences(of: "/", with: "_")
			.replacingOccurrences(of: "\\", with: "_")
		return sanitized.isEmpty ? fallback : sanitized
	}
}
