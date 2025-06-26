//
//  OptionsManager.swift
//  Feather
//
//  Created by samara on 15.04.2025.
//

import Foundation
import UIKit

// MARK: - Class
class OptionsManager: ObservableObject {
	static let shared = OptionsManager()
	
	@Published var options: Options
	private let _key = "signing_options"
	
	init() {
		if let data = UserDefaults.standard.data(forKey: _key),
		   let savedOptions = try? JSONDecoder().decode(Options.self, from: data) {
			self.options = savedOptions
		} else {
			self.options = Options.defaultOptions
			self.saveOptions()
		}
	}
	
	/// Saves options
	func saveOptions() {
		if let encoded = try? JSONEncoder().encode(options) {
			UserDefaults.standard.set(encoded, forKey: _key)
			objectWillChange.send()
		}
	}
	
	/// Resets options to default
	func resetToDefaults() {
		options = Options.defaultOptions
		saveOptions()
	}
}

// MARK: - Class Options
struct Options: Codable, Equatable {
	/// App name
	var appName: String?
	/// App version
	var appVersion: String?
	/// App bundle identifer
	var appIdentifier: String?
	/// App entitlements
	var appEntitlementsFile: URL?
	/// App apparence (i.e. Light/Dark/Default)
	var appAppearance: String
	/// App minimum iOS requirement (i.e. iOS 11.0)
	var minimumAppRequirement: String
	/// Inject path (i.e. `@rpath`)
	var injectPath: String
	/// Inject folder (i.e. `Frameworks/`)
	var injectFolder: String
	/// Random string appended to the app identifier
	var ppqString: String
	/// Basic protection against PPQ
	var ppqProtection: Bool
	/// (Better) protection against PPQ
	var dynamicProtection: Bool
	/// App identifiers list which matches and replaces
	var identifiers: [String: String]
	/// App name list which matches and replaces
	var displayNames: [String: String]
	/// Array of files (`.dylib`, `.deb` ) to extract and inject
	var injectionFiles: [URL]
	/// Mach-o load paths to remove (i.e. `@executable_path/demo1.dylib`)
	var disInjectionFiles: [String]
	/// App files to remove from (i.e. `Frameworks/CydiaSubstrate.framework`)
	var removeFiles: [String]
	/// If app should have filesharing forcefully enabled
	var fileSharing: Bool
	/// If app should have iTunes filesharing forcefully enabled
	var itunesFileSharing: Bool
	/// If app should have Pro Motion enabled (may not be needed)
	var proMotion: Bool
	/// If app should have Game Mode enabled
	var gameMode: Bool
	/// If app should use fullscreen (iPad mainly)
	var ipadFullscreen: Bool
	/// `Deprecated` If app shouldn't have device restrictions
	var removeSupportedDevices: Bool
	/// If app shouldn't have URL Schemes
	var removeURLScheme: Bool
	/// If app should not include a `embedded.mobileprovision` (useful for JB detection)
	var removeProvisioning: Bool
	/// `Deprecated` If app shouldn't include a "Watch Placeholder" (i.e. `Youtube Music` may include a useless app)
	var removeWatchPlaceholder: Bool
	/// Forcefully rename string files for App name
	var changeLanguageFilesForCustomDisplayName: Bool
	/// `Deprecated` If app should be Adhoc signed instead of normally signed
	var doAdhocSigning: Bool
	/// Signing options
	var signingOption: String
	/// Modifies app to support liquid glass
	var experiment_supportLiquidGlass: Bool
	/// Modifies application to use ElleKit instead of CydiaSubstrate
	var experiment_replaceSubstrateWithEllekit: Bool
	
	var post_installAppAfterSigned: Bool
	/// This will delete your imported application after signing, to save on using unneeded space.
	var post_deleteAppAfterSigned: Bool
	
	// default
	static let defaultOptions = Options(
		// pre-sign modifications
		appAppearance: appAppearanceValues[0],
		minimumAppRequirement: appMinimumAppRequirementValues[0],
		injectPath: injectPathValues[0],
		injectFolder: injectFolderValues[1],
		ppqString: randomString(),
		ppqProtection: false,
		dynamicProtection: false,
		identifiers: [:],
		displayNames: [:],
		injectionFiles: [],
		disInjectionFiles: [],
		removeFiles: [],
		fileSharing: false,
		itunesFileSharing: false,
		proMotion: false,
		gameMode: false,
		ipadFullscreen: false,
		removeSupportedDevices: false, // Deprecated
		removeURLScheme: false,
		removeProvisioning: false,
		removeWatchPlaceholder: false, // Deprecated
		changeLanguageFilesForCustomDisplayName: false,
		doAdhocSigning: false, // Deprecated
		signingOption: signingOptionValues[0],
		// pre-sign experiments
		experiment_supportLiquidGlass: false,
		experiment_replaceSubstrateWithEllekit: false,
		// post sign
		post_installAppAfterSigned: false,
		post_deleteAppAfterSigned: false
	)
	
	// MARK: duplicate values are not recommended!
	
	static let signingOptionValues = ["Default", "Adhoc"]
	/// Default values for `appAppearance`
	static let appAppearanceValues = ["Default", "Light", "Dark"]
	/// Default values for `minimumAppRequirement`
	static let appMinimumAppRequirementValues = ["Default", "16.0", "15.0", "14.0", "13.0", "12.0"]
	/// Default values for `injectPath`
	static let injectPathValues = ["@executable_path", "@rpath"]
	/// Default values for `injectFolder`
	static let injectFolderValues = ["/", "/Frameworks/"]
	/// Default random value for `ppqString`
	static func randomString() -> String {
		let letters = UUID().uuidString
		return String((0..<6).compactMap { _ in letters.randomElement() })
	}
}
