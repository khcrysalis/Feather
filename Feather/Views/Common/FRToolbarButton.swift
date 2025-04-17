//
//  ToolbarButtonWrapper.swift
//  Stars
//
//  Created by samara on 7.04.2025.
//

import SwiftUI

struct FRToolbarButton: ToolbarContent {
	private var _title: String
	private var _icon: String
	private var _style: FRToolbarMenuStyle
	private var _placement: ToolbarItemPlacement
	private var _isDisabled: Bool
	private var _inlined: FRToolbarAlignment
	private var _action: () -> Void
	
	init(
		_ title: String,
		systemImage: String,
		style: FRToolbarMenuStyle = .icon,
		placement: ToolbarItemPlacement = .automatic,
		isDisabled: Bool = false,
		alignment: FRToolbarAlignment = .none,
		action: @escaping () -> Void
	) {
		self._title = title
		self._icon = systemImage
		self._style = style
		self._placement = placement
		self._isDisabled = isDisabled
		self._inlined = alignment
		self._action = action
	}
	
	var body: some ToolbarContent {
		ToolbarItem(placement: _placement) {
			Button(action: _action) {
				FRButton(_title, systemImage: _icon, style: _style)
			}
			.disabled(_isDisabled)
			.alignment(for: _inlined)
		}
	}
}
