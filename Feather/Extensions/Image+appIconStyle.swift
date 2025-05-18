//
//  Image+appIconStyle.swift
//  Feather
//
//  Created by samara on 11.04.2025.
//

import SwiftUI

extension Image {
	/// Applies a certain style to an image
	func appIconStyle(size: CGFloat = 56, lineWidth: CGFloat = 1) -> some View {
		self.resizable()
            .scaledToFit()
			.frame(width: size, height: size)
            .overlay {
                RoundedRectangle(cornerRadius: size * 0.2337, style: .continuous)
                    .strokeBorder(.gray.opacity(0.3), lineWidth: lineWidth)
            }
            .clipShape(RoundedRectangle(cornerRadius: size * 0.2337, style: .continuous))
	}
}
