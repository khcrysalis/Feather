//
//  Certificate.swift
//  feather
//
//  Created by samara on 5/18/24.
//  Copyright (c) 2024 Samara M (khcrysalis)
//

import Foundation

// MARK: - Certificate (Mobileprovision file)
struct Certificate: Codable {
	var AppIDName: String
	var ApplicationIdentifierPrefix: [String]?
	var CreationDate: Date
	var Platform: [String]
	var IsXcodeManaged: Bool?
	var DeveloperCertificates: [Data]?
	var derEncodedProfile: Data
	var PPQCheck: Bool?
	var Entitlements: [String: AnyCodable]?
	var ExpirationDate: Date
	var Name: String
	var ProvisionsAllDevices: Bool?
	var ProvisionedDevices: [String]?
	var TeamIdentifier: [String]
	var TeamName: String
	var TimeToLive: Int
	var UUID: String
	var Version: Int

	enum CodingKeys: String, CodingKey {
		case AppIDName,
			 CreationDate,
			 Platform,
			 IsXcodeManaged,
			 DeveloperCertificates,
			 PPQCheck,
			 Entitlements,
			 ExpirationDate,
			 Name,
			 ProvisionedDevices,
			 TeamIdentifier,
			 TeamName,
			 TimeToLive,
			 UUID,
			 Version
		case derEncodedProfile = "DER-Encoded-Profile"
	}
}

struct AnyCodable: Codable {
	let value: Any
	
	init(_ value: Any) {
		self.value = value
	}
	
	init(from decoder: Decoder) throws {
		let container = try decoder.singleValueContainer()
		
		if container.decodeNil() {
			self.value = NSNull()
		} else if let bool = try? container.decode(Bool.self) {
			self.value = bool
		} else if let int = try? container.decode(Int.self) {
			self.value = int
		} else if let uint = try? container.decode(UInt.self) {
			self.value = uint
		} else if let double = try? container.decode(Double.self) {
			self.value = double
		} else if let string = try? container.decode(String.self) {
			self.value = string
		} else if let array = try? container.decode([AnyCodable].self) {
			self.value = array.map { $0.value }
		} else if let dictionary = try? container.decode([String: AnyCodable].self) {
			self.value = dictionary.mapValues { $0.value }
		} else {
			throw DecodingError.dataCorruptedError(in: container, debugDescription: "AnyCodable cannot decode value")
		}
	}
	
	func encode(to encoder: Encoder) throws {
		var container = encoder.singleValueContainer()
		
		switch self.value {
		case is NSNull:
			try container.encodeNil()
		case let bool as Bool:
			try container.encode(bool)
		case let int as Int:
			try container.encode(int)
		case let uint as UInt:
			try container.encode(uint)
		case let double as Double:
			try container.encode(double)
		case let string as String:
			try container.encode(string)
		case let array as [Any]:
			try container.encode(array.map { AnyCodable($0) })
		case let dictionary as [String: Any]:
			try container.encode(dictionary.mapValues { AnyCodable($0) })
		default:
			throw EncodingError.invalidValue(self.value, EncodingError.Context(codingPath: container.codingPath, debugDescription: "AnyCodable cannot encode value"))
		}
	}
}

