//
//  ToolbarMenuWrapper.swift
//  Stars
//
//  Created by samara on 7.04.2025.
//

import SwiftUI
#warning("move this somewhere else, but this is fine for now")
public enum ToolbarAlignment {
	case leading
	case trailing
	case none
}

public struct ToolbarMenuWrapper<Content>: ToolbarContent where Content: View {
	public enum ToolbarMenuWrapperStyle {
		case icon
		case text
	}
	
	private var _title: String
	private var _icon: String
	private var _style: ToolbarMenuWrapperStyle
	private var _placement: ToolbarItemPlacement
	private var _inlined: ToolbarAlignment
	private var _content: Content
	
	public init(
		_ title: String,
		systemImage: String,
		style: ToolbarMenuWrapperStyle = .icon,
		placement: ToolbarItemPlacement = .automatic,
		alignment: ToolbarAlignment = .none,
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
			.alignment(for: _inlined)
			
		}
	}
}

extension View {
	@ViewBuilder
	public func alignment(for alignment: ToolbarAlignment) -> some View {
		switch alignment {
		case .leading:
			self.padding(.leading, -18)
		case .trailing:
			self.padding(.trailing, -18)
		case .none:
			self
		}
	}
}
