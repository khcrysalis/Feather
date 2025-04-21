//
//  ToolbarButtonWrapper.swift
//  Stars
//
//  Created by samara on 7.04.2025.
//

import SwiftUI

enum FRToolbarButtonRole {
	case cancel
	case dismiss
	case close
}

struct FRToolbarButton: ToolbarContent {
	@Environment(\.dismiss) private var dismiss
	
	private var _title: String
	private var _icon: String
	private var _style: FRToolbarMenuStyle
	private var _placement: ToolbarItemPlacement
	private var _isDisabled: Bool
	private var _inlined: FRToolbarAlignment
	private var _action: () -> Void
	private var _role: FRToolbarButtonRole?
	
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
	
	init(
		role: FRToolbarButtonRole,
		placement: ToolbarItemPlacement = .cancellationAction,
		alignment: FRToolbarAlignment = .none
	) {
		self._role = role
		self._placement = placement
		self._inlined = alignment
		self._isDisabled = false
		self._action = {}
		
		switch role {
		case .cancel:
			self._title = "Cancel"
			self._icon = "xmark"
			self._style = .text
		case .dismiss:
			self._title = "Dismiss"
			self._icon = "chevron.left"
			self._style = .icon
		case .close:
			self._title = "Close"
			self._icon = "xmark"
			self._style = .icon
			self._placement = .topBarTrailing
		}
	}
	
	var body: some ToolbarContent {
		ToolbarItem(placement: _placement) {
			Button {
				switch _role {
				case .cancel, .dismiss, .close:
					dismiss()
				default:
					_action()
				}
			} label: {
				FRButton(_title, systemImage: _icon, style: _style)
			}
			.disabled(_isDisabled)
			.alignment(for: _inlined)
		}
	}
}
