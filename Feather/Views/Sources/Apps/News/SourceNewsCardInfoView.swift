//
//  SourceNewsCardInfoView.swift
//  Feather
//
//  Created by samara on 8.06.2025.
//

import SwiftUI
import AltSourceKit
import NukeUI
import NimbleViews

// MARK: - View
struct SourceNewsCardInfoView: View {
	var new: ASRepository.News
	
	// MARK: Body
	var body: some View {
		NavigationStack {
			ScrollView {
				VStack(alignment: .leading, spacing: 20) {
					ZStack(alignment: .bottomLeading) {
						let placeholderView = {
							Color.gray.opacity(0.2)
						}()
						
						if let iconURL = new.imageURL {
							LazyImage(url: iconURL) { state in
								if let image = state.image {
									Color.clear.overlay(
									image
										.resizable()
										.aspectRatio(contentMode: .fill)
									)
								} else {
									placeholderView
								}
							}
						} else {
							placeholderView
						}
					}
					.frame(height: 220)
					.frame(maxWidth: .infinity)
					.background(new.tintColor ?? Color.secondary)
					.clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
					.overlay(
						RoundedRectangle(cornerRadius: 12, style: .continuous)
							.strokeBorder(Color.gray.opacity(0.2), lineWidth: 1)
					)
					
					VStack(alignment: .leading, spacing: 12) {
						Text(new.title)
							.font(.title.bold())
							.foregroundStyle(.tint)
							.multilineTextAlignment(.leading)
						
						if !new.caption.isEmpty {
							Text(new.caption)
								.font(.body)
								.foregroundStyle(.secondary)
								.multilineTextAlignment(.leading)
						}
						
						if let url = new.url {
							Button {
								UIApplication.shared.open(url)
							} label: {
								NBSheetButton(title: .localized("Open"), systemImage: "arrow.up.right")
							}
							.buttonStyle(.plain)
						}
						
						if let date = new.date?.date {
							Text(date.formatted(date: .abbreviated, time: .omitted))
								.font(.footnote)
								.foregroundStyle(.secondary)
						}
					}
				}
				.frame(
					minWidth: 0,
					maxWidth: .infinity,
					minHeight: 0,
					maxHeight: .infinity,
					alignment: .topLeading
				)
				.padding()
			}
			.toolbar {
				NBToolbarButton(role: .close)
			}
		}
	}
}
