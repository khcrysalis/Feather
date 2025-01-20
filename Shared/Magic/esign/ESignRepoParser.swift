//
//  ESignParser.swift
//  feather
//
//  Created by samara on 20.01.2025.
//

import Foundation

class EsignDecryptor {
	private let input: String

	init(input: String) {
		self.input = input
	}

	func extractBase64() -> Data? {
		let pattern = #"source\[(.*?)\]"#
		
		if let regex = try? NSRegularExpression(pattern: pattern),
		   let match = regex.firstMatch(in: input, range: NSRange(input.startIndex..., in: input)),
		   let range = Range(match.range(at: 1), in: input) {
			
			let base64String = String(input[range])
			
			if let decodedData = Data(base64Encoded: base64String) {
				return decodedData
			} else {
				Debug.shared.log(message: "Failed to decode base64 string.", type: .error)
			}
		} else {
			Debug.shared.log(message: "Base64 string not found.", type: .error)
		}
		
		return nil
	}

	func decrypt(key: [UInt8], keyLength: Int) -> [String]? {
		guard let data = extractBase64() else {
			Debug.shared.log(message: "EsignDecryptor.decrypt: Not valid data?", type: .error)
			return nil
		}
		
		let encryptedBytes = [UInt8](data)
		var decryptedData = Data()
		var keyIndex = 0
		
		for encryptedByte in encryptedBytes {
			let decryptedByte = encryptedByte ^ key[keyIndex]
			decryptedData.append(decryptedByte)
			keyIndex = (keyIndex + 1) % keyLength
		}
		
		if let decryptedString = String(data: decryptedData, encoding: .utf8) {
			return decryptedString.components(separatedBy: "\n")
		} else {
			return nil
		}
	}
}
