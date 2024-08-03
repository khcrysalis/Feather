//
//  Certificate.swift
//  feather
//
//  Created by samara on 5/18/24.
//

import Foundation

// MARK: - Certificate (Mobileprovision file)
public struct Cert: Codable {
	public var AppIDName: String
	public var CreationDate: Date
	public var IsXcodeManaged: Bool
	public var derEncodedProfile: Data
	public var PPQCheck: Bool?
	public var ExpirationDate: Date
	public var Name: String
	public var TeamName: String
	public var TimeToLive: Int
	public var UUID: String
	public var Version: Int

	enum CodingKeys: String, CodingKey {
		case AppIDName,
			 CreationDate,
			 IsXcodeManaged,
			 //derEncodedProfile
			 PPQCheck,
			 ExpirationDate,
			 Name,
			 TeamName,
			 TimeToLive,
			 UUID,
			 Version
		case derEncodedProfile = "DER-Encoded-Profile"
	}
}

