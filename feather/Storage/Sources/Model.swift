//
//  Model.swift
//  feather
//
//  Created by samara on 5/18/24.
//

import Foundation

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
