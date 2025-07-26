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
	private var _inlined: NBToolbarAlignment
	private var _action: () -> Void
	private var _role: NBToolbarButtonRole?
	
	public init(
		_ title: String = "",
		systemImage: String = "",
		style: NBToolbarMenuStyle = .icon,
		placement: ToolbarItemPlacement = .automatic,
		isDisabled: Bool = false,
		alignment: NBToolbarAlignment = .none,
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
	
	public init(
		role: NBToolbarButtonRole,
		placement: ToolbarItemPlacement = .cancellationAction,
		alignment: NBToolbarAlignment = .none
	) {
		self._role = role
		self._placement = placement
		self._inlined = alignment
		self._isDisabled = false
		self._action = {}
		
		switch role {
		case .cancel:
			self._title = .localized("Cancel")
			self._icon = "xmark"
			if #available(iOS 19, *) {
				self._style = .text
			} else {
				self._style = .icon
			}
		case .dismiss:
			self._title = .localized("Dismiss")
			self._icon = "chevron.left"
			if #available(iOS 19, *) {
				self._style = .text
			} else {
				self._style = .icon
			}
		case .close:
			self._title = .localized("Close")
			self._icon = "xmark"
			if #available(iOS 19, *) {
				self._style = .text
			} else {
				self._style = .icon
			}
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
				if #available(iOS 19, *), _ignoreSolariumLinkedOnCheck {
					if _style == .icon {
						Image(systemName: _icon)
					} else {
						Label(_title, systemImage: _icon).labelStyle(.titleOnly)
					}
				} else {
					NBButton(_title, systemImage: _icon, style: _style)
				}
			}
			.disabled(_isDisabled)
			.alignment(for: _inlined)
		}
	}
}
