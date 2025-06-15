//
//  UIUserInterfaceStyle+cases.swift
//  Feather
//
//  Created by samara on 14.06.2025.
//

import UIKit

extension UIUserInterfaceStyle: @retroactive CaseIterable {
	public static var allCases: [UIUserInterfaceStyle] {
		[.unspecified, .dark, .light]
	}
	
	// dont translate
	var label: String {
		switch self {
		case .unspecified: "Default"
		case .dark: "Dark"
		case .light: "Light"
		@unknown default: .localized("Unknown")
		}
	}
}
