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
	let expiration: Date.ExpirationInfo?
	
	var body: some View {
		Text(expiration?.formatted ?? title)
			.lineLimit(0)
			.font(.headline.bold())
			.foregroundStyle((expiration == nil) ? Color.accentColor : .white)
			.padding(.horizontal, 12)
			.padding(.vertical, 6)
			.background(expiration?.color.opacity(0.85) ?? Color(uiColor: .quaternarySystemFill))
			.clipShape(Capsule())
	}
}

