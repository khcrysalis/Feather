//
//  UIDevice++.swift
//  Feather
//
//  Created by samara on 19.06.2025.
//

#if !APPSTORE
import UIKit.UIDevice

extension UIDevice {
	/// Booleen that checks if the app has application identifier capabilities (i.e. App Icon)
	var doesHaveAppIdCapabilities: Bool {
		guard let appIdentifier = Bundle.main.applicationIdentifier else { return true }
		if appIdentifier.contains("*") { return true }
		return Bundle.main.bundleIdentifier == appIdentifier
	}
}
#endif
