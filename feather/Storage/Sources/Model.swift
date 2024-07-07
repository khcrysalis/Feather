//
//  Model.swift
//  feather
//
//  Created by samara on 5/18/24.
//

import Foundation

// MARK: - Sources
public struct SourcesData: Codable {
	public var name: String?
	public var identifier: String
	
	public var sourceURL: URL?
	public var iconURL: URL?
	public var apps: [StoreAppsData]

	enum CodingKeys: String, CodingKey {
		case name,
			 identifier,
			 sourceURL,
			 iconURL,
			 apps
	}
}

public struct StoreAppsData: Codable {
	public var name: String
	public var developerName: String?
	public var subtitle: String?
	public var bundleIdentifier: String
	
	public var iconURL: URL?
	public var downloadURL: URL?
	public var size: Int?
	
	public var version: String?
	public var versions: [StoreAppsDataVersion]?
	public var versionDate: String?
	public var versionDescription: String?
	public var localizedDescription: String?
	
	enum CodingKeys: String, CodingKey {
		case name,
			 developerName,
			 subtitle,
			 bundleIdentifier,
			 iconURL,
			 downloadURL,
			 size,
			 version,
			 versions,
			 versionDate,
			 versionDescription
	}
}

public struct StoreAppsDataVersion: Codable {
	public var version: String
	// Legit 0 people know how to put a date inside of their fucking repo apart from the altstore creator themselves
//	public var date: Date?
	public var localizedDescription: String?
	public var downloadURL: URL
	public var size: Int?
	
	enum CodingKeys: String, CodingKey {
		case version,
//			 date,
			 localizedDescription,
			 downloadURL,
			 size
	}
}

// MARK: - Certificate (Mobileprovision file)
public struct Cert: Codable {
	public var AppIDName: String
	public var ApplicationIdentifierPrefix: [String]
	public var CreationDate: Date
	public var Platform: [String]
	public var IsXcodeManaged: Bool
	public var DeveloperCertificates: [Data]
	public var derEncodedProfile: Data
	public var PPQCheck: Bool?
	public var Entitlements: Entitlements
	public var ExpirationDate: Date
	public var Name: String
	public var ProvisionedDevices: [String]
	public var TeamIdentifier: [String]
	public var TeamName: String
	public var TimeToLive: Int
	public var UUID: String
	public var Version: Int

	enum CodingKeys: String, CodingKey {
		case AppIDName,
			 ApplicationIdentifierPrefix,
			 CreationDate,
			 Platform,
			 IsXcodeManaged,
			 DeveloperCertificates,
			 //derEncodedProfile
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

public struct Entitlements: Codable {
	public var applicationIdentifier: String
	public var keychainAccessGroups: [String]
	public var getTaskAllow: Bool
	public var comAppleDeveloperTeamIdentifier: String
	
	enum CodingKeys: String, CodingKey {
		case applicationIdentifier = "application-identifier"
		case keychainAccessGroups = "keychain-access-groups"
		case getTaskAllow = "get-task-allow"
		case comAppleDeveloperTeamIdentifier = "com.apple.developer.team-identifier"
	}
}
