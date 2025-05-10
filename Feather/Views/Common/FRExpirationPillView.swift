//
//  FRExpirationPillView.swift
//  Feather
//
//  Created by samara on 7.05.2025.
//

import SwiftUI

// MARK: - View
struct FRExpirationPillView: View {
	let title: String
	let showOverlay: Bool
	let expiration: Date.ExpirationInfo?
	
	var body: some View {
		let labelText = showOverlay ? title : (expiration?.formatted ?? title)
		let backgroundColor = showOverlay
		? Color(uiColor: .quaternarySystemFill)
		: (expiration?.color.opacity(0.85) ?? Color(uiColor: .quaternarySystemFill))
		
		Text(labelText)
			.lineLimit(0)
			.font(.headline.bold())
			.foregroundStyle((showOverlay || expiration == nil) ? .accent : .white)
			.padding(.horizontal, 12)
			.padding(.vertical, 6)
			.background(backgroundColor)
			.clipShape(Capsule())
			.overlay {
				if showOverlay, let expiration {
					Text(expiration.formatted)
						.font(.system(size: 9))
						.foregroundStyle(expiration.color.opacity(0.85))
						.offset(y: -23)
				}
			}
	}
}

