//
//  FRButton.swift
//  Feather
//
//  Created by samara on 16.04.2025.
//

import SwiftUI

struct FRButton: View {
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
		switch _style {
		case .icon:
			Image(systemName: _icon)
				.font(.system(size: 12, weight: .bold))
				.frame(width: 29, height: 29)
				.background(Color(uiColor: .secondarySystemGroupedBackground))
				.clipShape(Circle())
			
		case .text:
			Text(_title)
				.font(.system(size: 12, weight: .bold))
				.padding(.horizontal, 12)
				.frame(height: 29)
				.background(Color(uiColor: .secondarySystemGroupedBackground))
				.clipShape(Capsule())
		}
    }
}
