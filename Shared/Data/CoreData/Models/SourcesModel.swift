//
//  Sources.swift
//  feather
//
//  Created by samara on 7/29/24.
//

import Foundation
// MARK: - Sources
public struct SourcesData: Codable {
	public var name: String?
	public var identifier: String
	
	public var sourceURL: URL?
	public var iconURL: URL?
	public var apps: [StoreAppsData]
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
}

public struct StoreAppsDataVersion: Codable {
	public var version: String
	// Legit 0 people know how to put a date inside of their fucking repo apart from the altstore creator themselves
//	public var date: Date?
	public var localizedDescription: String?
	public var downloadURL: URL
	public var size: Int?
}
