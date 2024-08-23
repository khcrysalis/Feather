//
//  Certificate.swift
//  feather
//
//  Created by samara on 5/18/24.
//  Copyright (c) 2024 Samara M (khcrysalis)
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
			 PPQCheck,
			 ExpirationDate,
			 Name,
			 TeamName,
			 TimeToLive,
			 UUID,
			 Version
		case derEncodedProfile = "DER-Encoded-Profile"
	}
	
	public init(AppIDName: String, CreationDate: Date, IsXcodeManaged: Bool, derEncodedProfile: Data, PPQCheck: Bool?, ExpirationDate: Date, Name: String, TeamName: String, TimeToLive: Int, UUID: String, Version: Int) {
		self.AppIDName = AppIDName
		self.CreationDate = CreationDate
		self.IsXcodeManaged = IsXcodeManaged
		self.derEncodedProfile = derEncodedProfile
		self.PPQCheck = PPQCheck
		self.ExpirationDate = ExpirationDate
		self.Name = Name
		self.TeamName = TeamName
		self.TimeToLive = TimeToLive
		self.UUID = UUID
		self.Version = Version
	}
}

