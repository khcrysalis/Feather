//
//  Foundation.swift
//  feather
//
//  Created by samara on 25.08.2024.
//

import Foundation

extension Bundle {
	static func makeLocalizationBundle(preferredLanguageCode: String? = Preferences.preferredLanguageCode) -> Bundle {
		if let preferredLangCode = preferredLanguageCode,
		   let bundle = Bundle(path: Bundle.main.path(forResource: preferredLangCode, ofType: "lproj")!) {
			return bundle
		}
		
		return Bundle.main
	}
	
	// MAKE SURE TO UPDATE THIS WHENEVER `Preferences.preferredLanguageCode` IS CHANGED!!
	static var preferredLocalizationBundle = makeLocalizationBundle()
}

extension String {
	static func localized(_ name: String) -> String {
		return NSLocalizedString(name, bundle: .preferredLocalizationBundle, comment: "")
	}
	
	static func localized(_ name: String, arguments: CVarArg...) -> String {
		return String(format: NSLocalizedString(name, bundle: .preferredLocalizationBundle, comment: ""), arguments: arguments)
	}
	/// Localizes the current string using the main bundle.
	///
	/// - Returns: The localized string.
	func localized() -> String {
		return String.localized(self)
	}
}
