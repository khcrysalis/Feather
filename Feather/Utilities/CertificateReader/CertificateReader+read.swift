//
//  CertificateReader+read.swift
//  Feather
//
//  Created by samara on 16.04.2025.
//

import Foundation

extension CertificateReader {
	func readAndDecode() -> Certificate? {
		guard let file = file else { return nil }
		
		do {
			let fileData = try Data(contentsOf: file)
			
			guard let xmlRange = fileData.range(of: Data("<?xml".utf8)) else {
				print("XML start not found")
				return nil
			}
			
			let xmlData = fileData.subdata(in: xmlRange.lowerBound..<fileData.endIndex)
			
			let decoder = PropertyListDecoder()
			let data = try decoder.decode(Certificate.self, from: xmlData)
			return data
		} catch {
			print("Error extracting certificate: \(error.localizedDescription)")
			return nil
		}
	}
}
