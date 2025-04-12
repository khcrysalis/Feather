//
//  Bundle+versions.swift
//  Loader
//
//  Created by samara on 18.03.2025.
//

import Foundation.NSBundle

extension Bundle {
	var name: String {
		if let displayName = object(forInfoDictionaryKey: "CFBundleDisplayName") as? String {
			return displayName
		}
		if let name = object(forInfoDictionaryKey: "CFBundleName") as? String {
			return name
		}
		return object(forInfoDictionaryKey: "CFBundleExecutable") as? String ?? ""
	}

	var version: String {
		if let version = object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String {
			return version
		}
		
		return object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? ""
	}
	
	var iconFileName: String? {
		guard
			let icons = object(forInfoDictionaryKey: "CFBundleIcons") as? [String: Any],
			let primary = icons["CFBundlePrimaryIcon"] as? [String: Any],
			let files = primary["CFBundleIconFiles"] as? [String],
			let name = files.last
		else {
			return nil
		}
		return name
	}
}
