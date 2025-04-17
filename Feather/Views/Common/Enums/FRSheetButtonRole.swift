//
//  FRSheetButtonRole.swift
//  Feather
//
//  Created by samara on 17.04.2025.
//


import SwiftUI

enum FRSheetButtonRole {
	case primary
	case secondary
	
	var backgroundColor: Color {
		switch self {
		case .primary:
			return Color.accentColor
		case .secondary:
			return Color(uiColor: .secondarySystemGroupedBackground)
		}
	}
	
	var textColor: Color {
		switch self {
		case .primary:
			return .white
		case .secondary:
			return Color.accentColor
		}
	}
}