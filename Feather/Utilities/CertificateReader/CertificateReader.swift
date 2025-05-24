//
//  CertificateReader.swift
//  Feather
//
//  Created by samara on 16.04.2025.
//

import UIKit
import OSLog

class CertificateReader: NSObject {
	let file: URL?
	var decoded: Certificate?
	
	init(_ file: URL?) {
		self.file = file
		super.init()
		self.decoded = self._readAndDecode()
	}
	
	private func _readAndDecode() -> Certificate? {
		guard let file = file else { return nil }
		
		do {
			let fileData = try Data(contentsOf: file)
			
			guard let xmlRange = fileData.range(of: Data("<?xml".utf8)) else {
				Logger.misc.error("XML start not found")
				return nil
			}
			
			let xmlData = fileData.subdata(in: xmlRange.lowerBound..<fileData.endIndex)
			
			let decoder = PropertyListDecoder()
			let data = try decoder.decode(Certificate.self, from: xmlData)
			return data
		} catch {
			Logger.misc.error("Error extracting certificate: \(error.localizedDescription)")
			return nil
		}
	}
}
