//
//  ToolbarButtonWrapper.swift
//  Stars
//
//  Created by samara on 7.04.2025.
//

import SwiftUI
import NimbleExtensions

public struct NBToolbarButton: ToolbarContent {
	@Environment(\.dismiss) private var dismiss
	
	@AppStorage("com.apple.SwiftUI.IgnoreSolariumLinkedOnCheck")
	private var _ignoreSolariumLinkedOnCheck: Bool = false
	
	private var _title: String
	private var _icon: String
	private var _style: NBToolbarMenuStyle
	private var _placement: ToolbarItemPlacement
	private var _isDisabled: Bool
	private var _action: () -> Void
	private var _role: NBToolbarButtonRole?
	
	public init(
		_ title: String = "",
		systemImage: String = "",
		style: NBToolbarMenuStyle = .icon,
		placement: ToolbarItemPlacement = .automatic,
		isDisabled: Bool = false,
		action: @escaping () -> Void
	) {
		self._title = title
		self._icon = systemImage
		self._style = style
		self._placement = placement
		self._isDisabled = isDisabled
		self._action = action
	}
	
	public init(
		role: NBToolbarButtonRole,
		placement: ToolbarItemPlacement = .cancellationAction
	) {
		self._role = role
		self._placement = placement
		self._isDisabled = false
		self._action = {}
		
		switch role {
		case .cancel:
			self._title = .localized("Cancel")
			self._icon = "xmark"
			self._style = .icon
		case .dismiss:
			self._title = .localized("Dismiss")
			self._icon = "chevron.left"
			self._style = .icon
		case .close:
			self._title = .localized("Close")
			self._icon = "xmark"
			self._style = .icon
			self._placement = .topBarTrailing
		}
	}
	
	public var body: some ToolbarContent {
		ToolbarItem(placement: _placement) {
			Button {
				switch _role {
				case .cancel, .dismiss, .close:
					dismiss()
				default:
					_action()
				}
			} label: {
				if _style == .icon {
					Image(systemName: _icon)
				} else {
					Label(_title, systemImage: _icon).labelStyle(.titleOnly)
				}
			}
			.disabled(_isDisabled)
		}
	}
}
