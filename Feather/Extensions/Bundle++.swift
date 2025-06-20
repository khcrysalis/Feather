//
//  Bundle++.swift
//  Feather
//
//  Created by samara on 19.06.2025.
//

import Foundation.NSBundle
import UIKit

extension Bundle {
	/// Retrieves the application identifier entitlement value
	var applicationIdentifier: String? {
		guard let appID = getApplicationIdentifier() else { return nil }
		
		if let dotIndex = appID.firstIndex(of: ".") {
			let bundleIDStart = appID.index(after: dotIndex)
			return String(appID[bundleIDStart...])
		}
		
		return appID
	}
}
