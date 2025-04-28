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
	static public func disabled() -> Color {
		.secondary.opacity(0.8)
	}
}
