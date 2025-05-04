//
//  Import.swift
//  Esign
//
//  Created by samara on 30.04.2025.
//

import Foundation

final public class ASDeobfuscator {
	private var _code: String
	
	public init(with code: String) {
		self._code = code
	}
	
	func decode() -> [String] {
		return Self.decode(with: _code)
	}
	
	static func decode(with code: String) -> [String] {
		let trimmedCode = code.trimmingCharacters(in: .whitespacesAndNewlines)
		
		guard !trimmedCode.isEmpty else {
			return []
		}
		
		if trimmedCode.hasPrefix("source[") {
			return ASDecrypt(input: code).decrypt() ?? []
		}
		
		let base64Decoded = Self.decodeBase64(with: trimmedCode)
		if !base64Decoded.isEmpty {
			return base64Decoded
		}
		
		return trimmedCode
			.components(separatedBy: CharacterSet.newlines)
			.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
			.filter { !$0.isEmpty }
	}
	
	static func decodeBase64(with code: String) -> [String] {
		guard
			let data = Data(base64Encoded: code),
			let decodedString = String(data: data, encoding: .utf8)
		else {
			return []
		}
		
		let delimiters = ["[K$]", "[M$]"]
		guard let delimiter = delimiters.first(where: { decodedString.contains($0) }) else {
			return []
		}
		
		return decodedString
			.components(separatedBy: delimiter)
			.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
			.filter { !$0.isEmpty }
	}
}
