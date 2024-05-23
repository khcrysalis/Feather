//
//  Model.swift
//  feather
//
//  Created by samara on 5/18/24.
//

import Foundation

public struct Source: Codable {
	public var name: String?
	public var identifier: String
	
	public var sourceURL: URL?
	public var iconURL: URL?
	public var apps: [StoreApps]

	enum CodingKeys: String, CodingKey {
		case name,
			 identifier,
			 sourceURL,
			 iconURL,
			 apps
	}
}

public struct StoreApps: Codable {
	public var name: String
	public var developerName: String?
	public var subtitle: String?
	public var bundleIdentifier: String
	
	public var iconURL: URL?
	public var downloadURL: URL
	public var size: Int?
	
	public var version: String
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
			 versionDate,
			 versionDescription
	}
}

public struct SourceURL: Codable {
	public var sourceURL: URL
}
