//
//  SigningOptions.swift
//  feather
//
//  Created by samara on 25.10.2024.
//

import Foundation

//enum Orientation {
//	.top
//	.bottom
//	.left
//	.right
//}

struct MainSigningOptions {
	var name: String?
	var version: String?
	var bundleId: String?
	var iconURL: UIImage?

	var uuid: String?
	var removeInjectPaths: [String] = []
	
	let forceMinimumVersionString = ["Automatic", "15.0", "14.0", "13.0"]
	let forceLightDarkAppearenceString = ["Automatic", "Light", "Dark"]
	
	var certificate: Certificate?
}

struct SigningOptions: Codable {
	var ppqCheckProtection: Bool = false
	var dynamicProtection: Bool = false
	var installAfterSigned: Bool = false
	var immediatelyInstallFromSource: Bool = false
	
	var bundleIdConfig: [String: String] = [:]
	var displayNameConfig: [String: String] = [:]
	var toInject: [String] = []
	
	var removePlugins: Bool = false
	var forceFileSharing: Bool = true
	var removeSupportedDevices: Bool = true
	var removeURLScheme: Bool = false
	var forceProMotion: Bool = false
	var forceGameMode: Bool = false
	
	var forceForceFullScreen: Bool = false
	var forceiTunesFileSharing: Bool = true
	var forceTryToLocalize: Bool = false
	
	var removeProvisioningFile: Bool = true
	var removeWatchPlaceHolder: Bool = true
	
	var forceMinimumVersion: String = "Automatic"
	var forceLightDarkAppearence: String = "Automatic"
}

extension UserDefaults {
	static let signingDataKey = "defaultSigningData"
	
	static let defaultSigningData = SigningOptions()
	
	var signingOptions: SigningOptions {
		get {
			if let data = data(forKey: UserDefaults.signingDataKey),
			   let options = try? JSONDecoder().decode(SigningOptions.self, from: data) {
				return options
			}
			return UserDefaults.defaultSigningData
		}
		set {
			if let data = try? JSONEncoder().encode(newValue) {
				set(data, forKey: UserDefaults.signingDataKey)
			}
		}
	}
	
	func resetSigningOptions() {
		signingOptions = UserDefaults.defaultSigningData
	}
}

