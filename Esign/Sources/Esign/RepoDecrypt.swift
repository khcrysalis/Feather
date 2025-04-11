//
//  ESignKey.swift
//  feather
//
//  Created by samara on 20.01.2025.
//

import Foundation

public class eRepoDecrypt {
	private let input: String
	
	public init(input: String) {
		self.input = input
	}
	
	public func extractBase64() -> Data? {
		let pattern = #"source\[(.*?)\]"#
		
		if let regex = try? NSRegularExpression(pattern: pattern),
		   let match = regex.firstMatch(in: input, range: NSRange(input.startIndex..., in: input)),
		   let range = Range(match.range(at: 1), in: input) {
			
			let base64String = String(input[range])
			
			if let decodedData = Data(base64Encoded: base64String) {
				return decodedData
			} else {
				print("Esign: Failed to decode base64 string.")
			}
		} else {
			print("Esign: Base64 string not found.")
		}
		
		return nil
	}
	
	public func decrypt() -> [String]? {
		decrypt(key: esign_key, keyLength: esign_key_len)
	}
	
	public func decrypt(key: [UInt8], keyLength: Int) -> [String]? {
		guard let data = extractBase64() else {
			print("Esign: Not valid data?")
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
