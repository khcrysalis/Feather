//
//  SourceAppsCellView.swift
//  Feather
//
//  Created by samara on 3.05.2025.
//

import SwiftUI
import AltSourceKit
import NimbleViews
import Combine
import NukeUI

// thats a whole pharaghraph of codes
struct SourceAppsCellView: View {
	@AppStorage("Feather.storeCellAppearance") private var _storeCellAppearance: Int = 0
	
	var source: ASRepository
	var app: ASRepository.App
	
	var body: some View {
		VStack {
			HStack(spacing: 2) {
				FRIconCellView(
					title: app.currentName,
					subtitle: Self.appDescription(app: app),
					iconUrl: app.iconURL
				)
				.overlay(alignment: .bottomLeading) {
					if let iconURL = source.currentIconURL {
						LazyImage(url: iconURL) { state in
							if let image = state.image {
								image
									.appIconStyle(size: 20, isCircle: true, background: Color(uiColor: .secondarySystemBackground))
									.offset(x: 41, y: 4)
							}
						}
					}
				}
				DownloadButtonView(app: app)
			}
			
			if
				_storeCellAppearance != 0,
				let desc = app.localizedDescription
			{
				Text(desc)
					.frame(maxWidth: .infinity, alignment: .leading)
					.font(.subheadline)
					.foregroundStyle(.secondary)
					.padding(.top, 2)
			}
		}
	}
	
	static func appDescription(app: ASRepository.App) -> String {
		let optionalComponents: [String?] = [
			app.currentVersion,
			app.currentDescription ?? .localized("An awesome application")
		]
		
		let components: [String] = optionalComponents.compactMap { value in
			guard
				let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines),
				!trimmed.isEmpty
			else {
				return nil
			}
			
			return trimmed
		}
		
		return components.joined(separator: " • ")
	}
}
