//
//  PillItem.swift
//  Feather
//
//  Created by samara on 16.04.2025.
//

import SwiftUI

public struct NBPillItem: Identifiable {
	public let id = UUID()
	public let title: String
	public let icon: String
	public let color: Color
	
	public init(title: String, icon: String, color: Color) {
		self.title = title
		self.icon = icon
		self.color = color
	}
}
