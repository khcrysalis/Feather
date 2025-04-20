//
//  OptionsManager.swift
//  Feather
//
//  Created by samara on 15.04.2025.
//

import Foundation
import UIKit

class OptionsManager: ObservableObject {
	@Published var options: Options
	private let _key = "signing_options"
	
	static let shared = OptionsManager()
	
	init() {
		if let data = UserDefaults.standard.data(forKey: _key),
		   let savedOptions = try? JSONDecoder().decode(Options.self, from: data) {
			self.options = savedOptions
		} else {
			self.options = Options.defaultOptions
			self.saveOptions()
		}
	}
	
	func saveOptions() {
		if let encoded = try? JSONEncoder().encode(options) {
			UserDefaults.standard.set(encoded, forKey: _key)
			objectWillChange.send()
		}
	}
	
	func resetToDefaults() {
		options = Options.defaultOptions
		saveOptions()
	}
}

struct Options: Codable, Equatable {
	var appName: String?
	var appVersion: String?
	var appIdentifier: String?
	
	var appAppearance: String
	var minimumAppRequirement: String
	
	var ppqString: String
	
	var ppqProtection: Bool
	var dynamicProtection: Bool
	
	var identifiers: [String: String]
	var displayNames: [String: String]
	var injectionFiles: [String]
	var disInjectionFiles: [String]
	
	var fileSharing: Bool
	var itunesFileSharing: Bool
	var proMotion: Bool
	var gameMode: Bool
	var ipadFullscreen: Bool
	
	var removeSupportedDevices: Bool
	var removeURLScheme: Bool
	var removeProvisioning: Bool
	var removeWatchPlaceholder: Bool
	
	var changeLanguageFilesForCustomDisplayName: Bool
	// advanced
	var doAdhocSigning: Bool
	
	// default
	static let defaultOptions = Options(
		appAppearance: "Default",
		minimumAppRequirement: "Default",
		
		ppqString: randomString(),
		
		ppqProtection: false,
		dynamicProtection: false,
		
		identifiers: [:],
		displayNames: [:],
		injectionFiles: [],
		disInjectionFiles: [],
		
		fileSharing: false,
		itunesFileSharing: false,
		proMotion: false,
		gameMode: false,
		ipadFullscreen: false,
		
		removeSupportedDevices: false,
		removeURLScheme: false,
		removeProvisioning: false,
		removeWatchPlaceholder: false,
		
		changeLanguageFilesForCustomDisplayName: false,
		// advanced
		doAdhocSigning: false
	)
	
	static let appAppearanceValues = ["Default", "Light", "Dark"]
	static let appMinimumAppRequirementValues = ["Default", "16.0", "15.0", "14.0", "13.0", "12.0"]
	static func randomString(length: Int = 6) -> String {
		let letters = "abcdefghijklmnopqrstuvwxyz"
		return String((0..<length).compactMap { _ in letters.randomElement() })
	}
}
