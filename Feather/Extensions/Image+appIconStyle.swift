//
//  Image+appIconStyle.swift
//  Feather
//
//  Created by samara on 11.04.2025.
//

import SwiftUI

extension Image {
	/// Applies a certain style to an image
	func appIconStyle(size: CGFloat = 54, cornerRadius: CGFloat = 13, lineWidth: CGFloat = 1) -> some View {
		self.resizable()
			.frame(width: size, height: size)
			.clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
			.overlay(
				RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
					.stroke(Color.gray.opacity(0.3), lineWidth: lineWidth)
			)
	}
}
