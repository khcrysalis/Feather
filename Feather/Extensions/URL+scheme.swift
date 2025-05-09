//
//  URL+scheme.swift
//  Feather
//
//  Created by samara on 8.05.2025.
//

import Foundation.NSURL

extension URL {
	func validatedScheme(after marker: String) -> String? {
		guard let range = absoluteString.range(of: marker) else { return nil }
		let path = String(absoluteString[range.upperBound...])
		guard path.hasPrefix("https://") else { return nil }
		return path
	}
}
