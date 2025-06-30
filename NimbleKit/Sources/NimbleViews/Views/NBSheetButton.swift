//
//  NBSheetButton.swift
//  NimbleKit
//
//  Created by samara on 8.05.2025.
//

import SwiftUI

public struct NBSheetButton: View {
	public enum NSSheetButtonStyle {
		case prominent
		case standard
	}
	
	@Environment(\.isEnabled) private var isEnabled
	
	private var _title: String
	private var _systemImage: String?
	private var _style: NSSheetButtonStyle
	
	public init(
		title: String,
		systemImage: String? = nil,
		style: NSSheetButtonStyle = .standard
	) {
		self._title = title
		self._systemImage = systemImage
		self._style = style
	}
	
	public var body: some View {
		ZStack {
			if isEnabled {
				Label {
					Text(_title)
				} icon: {
					if let image = _systemImage {
						Image(systemName: image)
					}
				}
				.labelStyle(.titleAndIcon)
			} else {
				ProgressView()
					.progressViewStyle(.circular)
					.opacity(1)
			}
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.background(isEnabled ? backgroundColor : Color(uiColor: .quaternarySystemFill))
		.foregroundColor(foregroundColor)
		.clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
		.fontWeight(.semibold)
		.frame(height: 50)
	}
	
	@ViewBuilder
	private var content: some View {
		Label {
			Text(_title)
		} icon: {
			if let image = _systemImage {
				Image(systemName: image)
			}
		}
		.labelStyle(.titleAndIcon)
	}

	
	private var backgroundColor: Color {
		switch _style {
		case .prominent: 	.accentColor
		case .standard: 	Color(uiColor: .quaternarySystemFill)
		}
	}
	
	private var foregroundColor: Color {
		switch _style {
		case .prominent: 	.white
		case .standard: 	.accentColor
		}
	}
}
