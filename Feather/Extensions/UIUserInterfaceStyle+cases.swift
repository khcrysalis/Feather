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
	
	var label: String {
		switch self {
		case .unspecified: .localized("Default style")
		case .dark: .localized("Dark style")
		case .light: .localized("Light style")
		@unknown default: .localized("Unknown")
		}
	}
}
