//
//  LRActionButton.swift
//  Feather
//
//  Created by samara on 21.04.2025.
//

import SwiftUI

struct LRActionButton: View {
	private var _title: String
	private var _icon: String
	private var _style: FRToolbarMenuStyle
	
	init(
		_ title: String,
		systemImage: String,
		style: FRToolbarMenuStyle = .icon
	) {
		self._title = title
		self._icon = systemImage
		self._style = style
	}
	
	var body: some View {
		Group {
			switch _style {
			case .icon:
				Image(systemName: _icon)
					.font(.caption).bold()
				
			case .text:
				Text(_title)
					.font(.footnote).bold()
			}
		}
		.frame(width: 66, height: 29)
		.background(Color(uiColor: .quaternarySystemFill))
		.clipShape(Capsule())
	}
}
