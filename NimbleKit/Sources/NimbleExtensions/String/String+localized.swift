//
//  String+localized.swift
//  NimbleKit
//
//  Created by samara on 20.03.2025.
//

import Foundation.NSString
import SwiftUI

extension String {
	// from: https://github.com/NSAntoine/Antoine/blob/main/Antoine/Backend/Extensions/Foundation.swift#L43-L55
	// was given permission to use any code from antoine as I like - thank you Serena!~
	
	static public func localized(_ name: String) -> String {
		return NSLocalizedString(name, comment: "")
	}
	
	static public func localized(_ name: String, arguments: CVarArg...) -> String {
		return String(format: NSLocalizedString(name, comment: ""), arguments: arguments)
	}
	/// Localizes the current string using the main bundle.
	///
	/// - Returns: The localized string.
	public func localized() -> String {
		return String.localized(self)
	}
}

extension LocalizedStringKey {
	static public func localized(_ key: String) -> LocalizedStringKey {
		return LocalizedStringKey(key)
	}
}
