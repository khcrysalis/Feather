//
//  ToolbarMenuWrapper.swift
//  Stars
//
//  Created by samara on 7.04.2025.
//

import SwiftUI

public struct NBToolbarMenu<Content>: ToolbarContent where Content: View {
	private var _title: String
	private var _icon: String
	private var _style: NBToolbarMenuStyle
	private var _placement: ToolbarItemPlacement
	private var _inlined: NBToolbarAlignment
	private var _content: Content
	
	public init(
		_ title: String = "",
		systemImage: String = "",
		style: NBToolbarMenuStyle = .icon,
		placement: ToolbarItemPlacement = .automatic,
		alignment: NBToolbarAlignment = .none,
		@ViewBuilder content: () -> Content
	) {
		self._title = title
		self._icon = systemImage
		self._style = style
		self._placement = placement
		self._inlined = alignment
		self._content = content()
	}
	
	public var body: some ToolbarContent {
		ToolbarItem(placement: _placement) {
			Menu {
				_content
			} label: {
				if _style == .icon {
					Image(systemName: _icon)
				} else {
					Label(_title, systemImage: _icon)
				}
			}
			.alignment(for: _inlined)
			
		}
	}
}
