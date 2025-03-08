//
//  Sources.swift
//  feather
//
//  Created by samara on 7/29/24.
//  Copyright (c) 2024 Samara M (khcrysalis)
//

import Foundation

// MARK: - Sources
public struct SourcesData: Codable, Hashable {
	public var name: String?
	public var identifier: String
	public var tintColor: String?
	
	public var sourceURL: URL?
	public var iconURL: URL?
	public var website: String?
	public var news: [NewsData]?
	public var apps: [StoreAppsData]
	
	public static func == (lhs: SourcesData, rhs: SourcesData) -> Bool {
		return lhs.identifier == rhs.identifier
	}
	
	public func hash(into hasher: inout Hasher) {
		hasher.combine(identifier)
	}
}

public struct NewsData: Codable, Hashable {
	public let title: String?
	public let identifier: String
	public let caption: String?
	public let tintColor: String?
	public let imageURL: String?
	public let url: URL?
	public let date: String
	public let appID: String?
}

public struct StoreAppsData: Codable {
	public var name: String
	public var developerName: String?
	public var subtitle: String?
	public var bundleIdentifier: String
	
	public var iconURL: URL?
	public var downloadURL: URL?
	public var size: Int?
	public var screenshotURLs: [URL]?
	public var screenshots: [Screenshot]?
	
	public var version: String?
	public var versions: [StoreAppsDataVersion]?
	public var versionDate: String?
	public var versionDescription: String?
	public var localizedDescription: String?
	
	enum CodingKeys: String, CodingKey {
		case name, developerName, subtitle, bundleIdentifier
		case iconURL, downloadURL, size
		case screenshotURLs, screenshots
		case version, versions, versionDate, versionDescription, localizedDescription
	}
	
	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		
		name = try container.decode(String.self, forKey: .name)
		developerName = try? container.decode(String.self, forKey: .developerName)
		subtitle = try? container.decode(String.self, forKey: .subtitle)
		bundleIdentifier = try container.decode(String.self, forKey: .bundleIdentifier)
		
		iconURL = try? container.decode(URL.self, forKey: .iconURL)
		downloadURL = try? container.decode(URL.self, forKey: .downloadURL)
		size = try? container.decode(Int.self, forKey: .size)
		
		screenshotURLs = try? container.decode([URL].self, forKey: .screenshotURLs)
		
		// Handle mixed types for `screenshots`
		if let urls = try? container.decode([String].self, forKey: .screenshots) {
			self.screenshots = urls.compactMap { URL(string: $0) }.map { Screenshot(imageURL: $0) }
		} else {
			self.screenshots = try? container.decode([Screenshot].self, forKey: .screenshots)
		}
		
		version = try? container.decode(String.self, forKey: .version)
		versions = try? container.decode([StoreAppsDataVersion].self, forKey: .versions)
		versionDate = try? container.decode(String.self, forKey: .versionDate)
		versionDescription = try? container.decode(String.self, forKey: .versionDescription)
		localizedDescription = try? container.decode(String.self, forKey: .localizedDescription)
	}
}

public struct Screenshot: Codable {
	public var imageURL: URL
	public var width: Int?
	public var height: Int?
	
	public init(imageURL: URL, width: Int? = nil, height: Int? = nil) {
		self.imageURL = imageURL
		self.width = width
		self.height = height
	}
}

public struct StoreAppsDataVersion: Codable {
	public var version: String
	public var localizedDescription: String?
	public var downloadURL: URL
	public var size: Int?
	public var date: String?
}
