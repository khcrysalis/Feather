//
//  URL+toSharedDocuments.swift
//  Feather
//
//  Created by samara on 14.04.2025.
//

import Foundation.NSURL

extension URL {
	/// Convert normal url to one that can be opened with files app
	public func toSharedDocumentsURL() -> URL? {
		let urlString = self.absoluteString
		
		guard urlString.hasPrefix("file://") else {
			return nil
		}
		
		let newURLString = "shareddocuments://" + urlString.dropFirst("file://".count)
		return URL(string: newURLString)
	}
}
