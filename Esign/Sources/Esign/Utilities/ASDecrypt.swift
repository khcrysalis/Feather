//
//  ESignKey.swift
//  feather
//
//  Created by samara on 20.01.2025.
//

import Foundation

public class ASDecrypt {
	private let _input: String
	
	public init(input: String) {
		self._input = input
	}
	
	public func extractBase64() -> Data? {
		let pattern = #"source\[(.*?)\]"#
		
		if let regex = try? NSRegularExpression(pattern: pattern),
		   let match = regex.firstMatch(in: _input, range: NSRange(_input.startIndex..., in: _input)),
		   let range = Range(match.range(at: 1), in: _input) {
			
			let base64String = String(_input[range])
			
			if let decodedData = Data(base64Encoded: base64String) {
				return decodedData
			}
		}
		
		return nil
	}
	
	public func decrypt() -> [String]? {
		decrypt(key: esign_key, keyLength: esign_key_len)
	}
	
	public func decrypt(key: [UInt8], keyLength: Int) -> [String]? {
		guard let data = extractBase64() else {
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
