//
//  Repository.swift
//  Feather
//
//  Created by Lakhan Lothiyi on 19/04/2025.
//

import Foundation
import SwiftUI

// Evidently, every repo is silly, they all have slightly different formats :c
// only altstore repo (ofc) has the correct format.
// we're going to use a defensive approach and try to parse many repos.

// MARK: - Repository

public struct ASRepository: Sendable, Decodable, Hashable, Identifiable {
	// Core data
	public var id: String?
	public var name: String?

	// descriptive fields
	public var subtitle: String?
	public var description: String?
	public var website: URL?
	public var iconURL: URL?
	public var headerURL: URL?
	public var tintColor: Color?

	// special fields
	public var patreonURL: URL?
	public var userInfo: UserInfo?

	// apps, news etc.
	public var apps: [App]
	public var featuredApps: [App.ID]?
	public var news: [News]?

	public init(from decoder: any Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.id = try container.decodeIfPresent(String.self, forKey: .id)
		self.name = try container.decodeIfPresent(String.self, forKey: .name)

		self.subtitle = try container.decodeIfPresent(
			String.self,
			forKey: .subtitle
		)
		self.description = try container.decodeIfPresent(
			String.self,
			forKey: .description
		)
		self.website = try container.decodeIfPresent(URL.self, forKey: .website)
		self.iconURL = try container.decodeIfPresent(
			URL.self,
			forKey: .iconURL
		)
		self.headerURL = try container.decodeIfPresent(
			URL.self,
			forKey: .headerURL
		)
		self.tintColor =
			try container.decodeIfPresent(Color.self, forKey: .tintColor)

		self.patreonURL = try container.decodeIfPresent(
			URL.self,
			forKey: .patreonURL
		)
		self.userInfo = try container.decodeIfPresent(
			UserInfo.self,
			forKey: .userInfo
		)

		self.apps = try container.decodeIfPresent([App].self, forKey: .apps) ?? []
		self.featuredApps =
			try container.decodeIfPresent([App.ID].self, forKey: .featuredApps) ?? []
		self.news = try container.decodeIfPresent([News].self, forKey: .news) ?? []
	}

	public enum CodingKeys: String, CodingKey {
		case id = "identifier"
		case name,
			 subtitle,
			 description,
			 website,
			 patreonURL,
			 userInfo,
			 iconURL,
			 headerURL,
			 tintColor,
			 apps,
			 featuredApps,
			 news
	}
	
	public var currentIconURL: URL? {
		iconURL ?? apps.first?.iconURL
	}

	//	func encode(to encoder: any Encoder) throws {
	//		var container = encoder.container(keyedBy: CodingKeys.self)
	//		try container.encode(id, forKey: .id)
	//		try container.encode(name, forKey: .name)
	//
	//		try container.encodeIfPresent(subtitle, forKey: .subtitle)
	//		try container.encodeIfPresent(description, forKey: .description)
	//		try container.encodeIfPresent(website, forKey: .website)
	//
	//		try container.encodeIfPresent(patreonURL, forKey: .patreonURL)
	//		try container.encodeIfPresent(userInfo, forKey: .userInfo)
	//
	//		try container.encodeIfPresent(apps, forKey: .apps)
	//		try container.encodeIfPresent(featuredApps, forKey: .featuredApps)
	//		try container.encodeIfPresent(news, forKey: .news)
	//	}
}

// MARK: - App

extension ASRepository {
	public struct App: Sendable, Decodable, Hashable, Identifiable {
		public var uuid = UUID()
		
		public var id: String?
		public var name: String?

		public var subtitle: String?
		public var description: String?

		public var developer: String?

		public var versions: [Version]?

		public var version: String?

		public var versionDate: DateParsed?

		public var versionDescription: String?

		public var downloadURL: URL?

		public var localizedDescription: String?

		public var iconURL: URL?

		public var tintColor: Color?

		public var size: UInt?

		public var category: String?

		public var beta: Bool?

		public var permissions: [Permission]?

		public var appPermissions: AppPermissions?

		public var screenshots: Screenshots?

		public var screenshotURLs: [URL]?

		public struct Screenshots: Decodable, Hashable, Sendable {
			public var iPhone: [URL]?
			public var iPad: [URL]?

			public init(from decoder: any Decoder) throws {
				// theres a bunch of ways this shit can be formatted
				// 1. an array of urls (strings)
				// 2. an array of dictionaries that contain url, width, height.
				// 3. a mix of 1 and 2, having urls or dictionaries
				// 4. a dictionary with properties for iphone and ipad, which are arrays of above types

				#warning("implement screenshots decoding")

				self.iPad = []
				self.iPhone = []
			}

			public enum CodingKeys: String, CodingKey {
				case iPhone = "iphone"
				case iPad = "ipad"
				case url
			}
		}

		public init(from decoder: any Decoder) throws {
			let container = try decoder.container(keyedBy: CodingKeys.self)
			self.id = try container.decodeIfPresent(String.self, forKey: .id)
			self.name = try container.decodeIfPresent(String.self, forKey: .name)

			self.subtitle = try container.decodeIfPresent(
				String.self,
				forKey: .subtitle
			)
			self.description = try container.decodeIfPresent(
				String.self,
				forKey: .description
			)

			self.developer = try container.decodeIfPresent(String.self, forKey: .developer)

			self.versions = try container.decodeIfPresent(
				[Version].self,
				forKey: .versions
			)

			self.version = try container.decodeIfPresent(
				String.self,
				forKey: .version
			)

			self.versionDate = try container.decodeIfPresent(
				DateParsed.self,
				forKey: .versionDate
			)

			self.versionDescription = try container.decodeIfPresent(
				String.self,
				forKey: .versionDescription
			)

			self.downloadURL = try container.decodeIfPresent(URL.self, forKey: .downloadURL)

			self.localizedDescription =
				try container.decodeIfPresent(
					String.self,
					forKey: .localizedDescription
				)

			self.iconURL = try container.decode(URL.self, forKey: .iconURL)

			self.tintColor =
				try container.decodeIfPresent(Color.self, forKey: .tintColor)

			self.size =
				(try? container.decodeIfPresent(UInt.self, forKey: .size))
				?? (try? container.decodeIfPresent(String.self, forKey: .size))
				.flatMap { UInt($0) }

			self.category = try container.decodeIfPresent(
				String.self,
				forKey: .category
			)

			self.beta =
				(try? container.decodeIfPresent(Bool.self, forKey: .beta)) ?? false

			self.permissions = try container.decodeIfPresent(
				[Permission].self,
				forKey: .permissions
			)
			self.appPermissions = try container.decodeIfPresent(
				AppPermissions.self,
				forKey: .appPermissions
			)

			self.screenshots = try container.decodeIfPresent(
				Screenshots.self,
				forKey: .screenshots
			)

			self.screenshotURLs =
				try container.decodeIfPresent([URL].self, forKey: .screenshotURLs)
		}

		//		func encode(to encoder: any Encoder) throws {
		//			var container = encoder.container(keyedBy: CodingKeys.self)
		//			try container.encode(id, forKey: .id)
		//			try container.encode(name, forKey: .name)
		//
		//			try container.encodeIfPresent(subtitle, forKey: .subtitle)
		//			try container.encodeIfPresent(description, forKey: .description)
		//
		//			try container.encode(developer, forKey: .developer)
		//
		//			try container.encode(versions, forKey: .versions)
		//
		//			try container.encode(version, forKey: .version)
		//
		//			try container.encode(versionDate, forKey: .versionDate)
		//
		//			try container.encodeIfPresent(versionDescription, forKey: .versionDescription)
		//
		//			try container.encode(downloadURL, forKey: .downloadURL)
		//
		//			try container.encode(localizedDescription, forKey: .localizedDescription)
		//
		//			try container.encode(iconURL, forKey: .iconURL)
		//
		//			try container.encodeIfPresent(tintColor, forKey: .tintColor)
		//
		//			if let size = size {
		//				try container.encode(size, forKey: .size)
		//			}
		//
		//			try container.encode(category, forKey: .category)
		//			try container.encode(beta, forKey: .beta)
		//
		//			// try container.encode(permissions, forKey: .permissions)
		//			// try container.encode(appPermissions, forKey: .appPermissions)
		//
		//			try container.encode(screenshots, forKey: .screenshots)
		//		}

		public enum CodingKeys: String, CodingKey {
			case id = "bundleIdentifier"
			case name, subtitle, description
			case developer = "developerName"
			case versions, version, versionDate, versionDescription, downloadURL,
				localizedDescription, iconURL, tintColor, size, category, beta
			case permissions, appPermissions
			case screenshots, screenshotURLs
		}
		
		public var currentAppVersion: Version? {
			versions?.sorted(path: \.version).last
		}
		
		public var currentName: String {
			var name = name ?? "Unknown"
			// additional check for blank names
			if name.isEmpty { name = "Unknown" }
			
			if let id, id.hasSuffix("Beta") {
				name += " (BETA)"
			}
			
			return name
		}
		
		public var currentVersion: String? {
			currentAppVersion?.version ?? version
		}
		
		public var currentDownloadUrl: URL? {
			currentAppVersion?.downloadURL ?? downloadURL
		}
		
		public var currentDate: DateParsed? {
			currentAppVersion?.date ?? versionDate
		}
		
		// "UNIQUE" hahaha
		public var currentUniqueId: String {
			"\(id ?? uuid.uuidString).\(downloadURL?.absoluteString ?? uuid.uuidString)"
		}

		public struct Version: Decodable, Hashable, Identifiable, Comparable, Sendable {
			public var id: String { version + (build ?? "") }
			public var version: String
			public var build: String?
			public var date: DateParsed?
			public var localizedDescription: String?
			public var downloadURL: URL?
			public var size: UInt?
			public var minOSVersion: OSVersion?

			public init(from decoder: any Decoder) throws {
				let container = try decoder.container(keyedBy: CodingKeys.self)
				self.version = try container.decode(String.self, forKey: .version)
				self.build = try container.decodeIfPresent(
					String.self,
					forKey: .build
				)
				self.date = try container.decodeIfPresent(
					DateParsed.self,
					forKey: .date
				)
				self.localizedDescription =
					try container.decodeIfPresent(
						String.self,
						forKey: .localizedDescription
					)
				self.downloadURL = try container.decodeIfPresent(
					URL.self,
					forKey: .downloadURL
				)
				self.size =
					(try? container.decodeIfPresent(UInt.self, forKey: .size))
					?? (try? container.decodeIfPresent(String.self, forKey: .size))
					.flatMap { UInt($0) }
				self.minOSVersion = try container.decodeIfPresent(
					OSVersion.self,
					forKey: .minOSVersion
				)
			}

			static public func < (lhs: Self, rhs: Self) -> Bool {
				// compare id
				lhs.id < rhs.id
			}

			public enum CodingKeys: String, CodingKey {
				case version
				case build = "buildVersion"
				case date, localizedDescription, downloadURL, size, minOSVersion
			}
		}
	}
}

// MARK: - News

extension ASRepository {
	public struct News: Sendable, Decodable, Hashable, Identifiable {
		public var id: String
		public var title: String
		public var caption: String
		public var tintColor: Color?
		public var imageURL: URL?
		public var appID: App.ID?
		public var date: DateParsed?
		public var notify: Bool

		public init(from decoder: any Decoder) throws {
			let container = try decoder.container(keyedBy: CodingKeys.self)
			self.id = try container.decode(String.self, forKey: .id)
			self.title = try container.decode(String.self, forKey: .title)
			self.caption = try container.decode(String.self, forKey: .caption)
			self.tintColor = try container.decodeIfPresent(
				Color.self,
				forKey: .tintColor
			)
			self.imageURL = try container.decodeIfPresent(URL.self, forKey: .imageURL)
			self.appID = try container.decodeIfPresent(App.ID.self, forKey: .appID)
			self.date = try container.decodeIfPresent(DateParsed.self, forKey: .date)
			self.notify =
				try container.decodeIfPresent(Bool.self, forKey: .notify) ?? false
		}

		public enum CodingKeys: String, CodingKey {
			case id = "identifier"
			case title, caption, tintColor, imageURL, appID, date, notify
		}
	}
}

extension ASRepository {
	public struct Permission: Decodable, Hashable, Sendable {
		public var type: String
		public var usageDescription: String
	}
}

extension ASRepository {
	public struct AppPermissions: Decodable, Hashable, Sendable {
		public var entitlements: [Entitlement]?
		public var privacy: [Privacy]?

		public struct Entitlement: Decodable, Hashable, Sendable {
			public var name: String

			public init(from decoder: any Decoder) throws {
				let container = try decoder.singleValueContainer()
				self.name = try container.decode(String.self)
			}
		}

		public struct Privacy: Decodable, Hashable, Sendable {
			var name: String
			var usageDescription: String
		}

		public init(from decoder: any Decoder) throws {
			let container = try decoder.container(keyedBy: CodingKeys.self)
			self.entitlements = try? container.decodeIfPresent(
				[Entitlement].self,
				forKey: .entitlements
			)
			// some people are silly and are using empty dictionaries instead of empty arrays so lets ignore decoding errors
			self.privacy = try? container.decodeIfPresent(
				[Privacy].self,
				forKey: .privacy
			)
		}

		public enum CodingKeys: String, CodingKey {
			case entitlements
			case privacy
		}
	}
}

extension ASRepository {
	public struct UserInfo: Decodable, Hashable, Sendable {
		public var patreonAccessToken: String?
	}
}

// MARK: - DateParsed

// everyone keeps using different formats for dates, even altstore

// taken from meret
public struct DateParsed: Codable, Equatable, Hashable, Comparable, Sendable {
	public let date: Date
	public let rawDate: RawDate

	public enum RawDate: Decodable, Sendable {
		case number(Double)
		case string(String)
	}

	// buncha date formats, i asked ai to make a list of these
	private static let formatters: [DateFormatter] = {
		[
			// ISO8601 with fractional seconds
			{
				let formatter = DateFormatter()
				formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
				return formatter
			}(),
			// ISO8601 with no fractional seconds and no timezone
			{
				let formatter = DateFormatter()
				formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
				return formatter
			}(),
			// ISO8601 without fractional seconds
			{
				let formatter = DateFormatter()
				formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
				return formatter
			}(),
			// Date only
			{
				let formatter = DateFormatter()
				formatter.dateFormat = "yyyy-MM-dd"
				return formatter
			}(),
			// HTTP date format (RFC 1123)
			{
				let formatter = DateFormatter()
				formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss zzz"
				formatter.locale = Locale(identifier: "en_US_POSIX")
				return formatter
			}(),
			// Twitter date format
			{
				let formatter = DateFormatter()
				formatter.dateFormat = "EEE MMM dd HH:mm:ss Z yyyy"
				formatter.locale = Locale(identifier: "en_US_POSIX")
				return formatter
			}(),
			// Unix timestamp (as string)
			{
				let formatter = DateFormatter()
				formatter.dateFormat = "x"
				return formatter
			}(),
			// Standard timestamp with space
			{
				let formatter = DateFormatter()
				formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
				return formatter
			}(),
		]
	}()



	public init(from decoder: Decoder) throws {
		let container = try decoder.singleValueContainer()
		// prevent nil
		if container.decodeNil() {
			throw DecodingError.valueNotFound(
				Date.self,
				DecodingError.Context(
					codingPath: decoder.codingPath,
					debugDescription:
						"Found nil for date :c\n\nPls ensure you mark the date type as optional in the Decodable struct you used this in."
				)
			)
		}

		// attempt decode as number, then parse as date
		do {
			let timestamp = try container.decode(TimeInterval.self)
			self.rawDate = .number(timestamp)

			self.date = Date(timeIntervalSince1970: timestamp)
			return
		} catch { /* failed parse as number, move on */  }

		// decode as string
		do {
			let dateString = try container.decode(String.self)
			self.rawDate = .string(dateString)

			// go thru all formatters and try to parse
			for formatter in Self.formatters {
				if let date = formatter.date(from: dateString) {
					self.date = date
					return
				}
			}
		} catch {}
		// ok lets actually handle this error now since we exhausted all options
		throw DecodingError.dataCorruptedError(
			in: container,
			debugDescription: "Cannot decode date, exhausted all options."
		)
	}

	public func encode(to encoder: Encoder) throws {
		var container = encoder.singleValueContainer()
		try container.encode(date)
	}

	// allows use of date in comparisons without having to unwrap

	public static func == (lhs: Self, rhs: Date) -> Bool {
		return lhs.date == rhs
	}

	public static func == (lhs: Self, rhs: Self) -> Bool {
		return lhs.date == rhs.date
	}

	public func hash(into hasher: inout Hasher) {
		hasher.combine(date)
	}

	public static func < (lhs: Self, rhs: Self) -> Bool {
		return lhs.date < rhs.date
	}
}

public struct OSVersion: Decodable, Hashable, CustomStringConvertible, Sendable {
	public var description: String {
		return "\(majorVersion).\(minorVersion).\(patchVersion)"
	}

	public var majorVersion: UInt
	public var minorVersion: UInt
	public var patchVersion: UInt

	public init(from decoder: any Decoder) throws {
		let container = try decoder.singleValueContainer()
		let versionString = try container.decode(String.self)

		let components = versionString.split(separator: ".").compactMap { UInt($0) }

		self.majorVersion = components[safe: 0] ?? 0
		self.minorVersion = components[safe: 1] ?? 0
		self.patchVersion = components[safe: 2] ?? 0
	}
}
