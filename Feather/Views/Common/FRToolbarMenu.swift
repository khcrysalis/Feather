//
//  ToolbarMenuWrapper.swift
//  Stars
//
//  Created by samara on 7.04.2025.
//

import SwiftUI

struct FRToolbarMenu<Content>: ToolbarContent where Content: View {
	private var _title: String
	private var _icon: String
	private var _style: FRToolbarMenuStyle
	private var _placement: ToolbarItemPlacement
	private var _inlined: FRToolbarAlignment
	private var _content: Content
	
	init(
		_ title: String,
		systemImage: String,
		style: FRToolbarMenuStyle = .icon,
		placement: ToolbarItemPlacement = .automatic,
		alignment: FRToolbarAlignment = .none,
		@ViewBuilder content: () -> Content
	) {
		self._title = title
		self._icon = systemImage
		self._style = style
		self._placement = placement
		self._inlined = alignment
		self._content = content()
	}
	
	var body: some ToolbarContent {
		ToolbarItem(placement: _placement) {
			Menu {
				_content
			} label: {
				FRButton(_title, systemImage: _icon, style: _style)
			}
			.alignment(for: _inlined)
			
		}
	}
}
