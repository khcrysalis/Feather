//
//  ServerPack.swift
//  feather
//
//  Created by samara on 23.01.2025.
//

// we should prompt the user to download these when finishing the onboarding, and make the exact same way of downloading the files in the server options
struct ServerPack: Decodable {
	var cert: String
	var ca: String
	var key: String
	var info: ServerPackInfo
	
	private enum CodingKeys: String, CodingKey {
		case cert, ca, key1, key2, info
	}
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		cert = try container.decode(String.self, forKey: .cert)
		ca = try container.decode(String.self, forKey: .ca)
		let key1 = try container.decode(String.self, forKey: .key1)
		let key2 = try container.decode(String.self, forKey: .key2)
		key = key1 + key2
		info = try container.decode(ServerPackInfo.self, forKey: .info)
	}
}

struct ServerPackInfo: Decodable {
	var issuer: Issuer
	var domains: Domains
}

struct Issuer: Decodable {
	var commonName: String
	
	private enum CodingKeys: String, CodingKey {
		case commonName = "commonName"
	}
}

struct Domains: Decodable {
	var commonName: String
	
	private enum CodingKeys: String, CodingKey {
		case commonName = "commonName"
	}
}
