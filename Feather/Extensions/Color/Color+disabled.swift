//
//  UIColor+disabled.swift
//  Feather
//
//  Created by samara on 16.04.2025.
//

import SwiftUI

extension Color {
	/// Disabled color
	/// - Parameter color: Color
	/// - Returns: "Disabled" version of specified color
	static func disabled(_ color: Color) -> Color {
		color.opacity(0.5)
	}
}
