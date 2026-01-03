//
//  String+PathSanitize.swift
//  Feather
//
//  Created by Jacob Prezant on 1/2/26
//

import Foundation

extension NSString {
	static func safePathComponent(_ input: String, fallback: String) -> String {
		let sanitized = input
			.replacingOccurrences(of: "..", with: "_")
			.replacingOccurrences(of: "/", with: "_")
			.replacingOccurrences(of: "\\", with: "_")
		return sanitized.isEmpty ? fallback : sanitized
	}
}
