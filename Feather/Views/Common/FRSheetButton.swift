//
//  FRSheetButton.swift
//  Feather
//
//  Created by samara on 17.04.2025.
//


import SwiftUI

struct FRSheetButton: View {
	@Environment(\.dismiss) private var dismiss
	
	private var _title: String
	private var _role: FRSheetButtonRole
	private var _action: () -> Void
	
	init(
		_ title: String,
		role: FRSheetButtonRole = .primary,
		action: @escaping () -> Void
	) {
		self._title = title
		self._role = role
		self._action = action
	}
	
	var body: some View {
		Button(action: {
			_action()
			dismiss()
		}) {
			Text(_title)
				.frame(maxWidth: .infinity, maxHeight: .infinity)
				.background(_role.backgroundColor)
				.foregroundColor(_role.textColor)
				.clipShape(
					RoundedRectangle(cornerRadius: 12, style: .continuous)
				)
				.bold()
		}
	}
}
