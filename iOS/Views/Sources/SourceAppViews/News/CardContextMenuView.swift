//
//  CardContextMenuView.swift
//  feather
//
//  Created by samara on 4.02.2025.
//

import SwiftUI

struct CardContextMenuView: View {
	@Environment(\.dismiss) var dismiss
	
	let news: NewsData
	
	var formattedDate: String {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd"
		if let date = dateFormatter.date(from: news.date) {
			return date.formatted(.relative(presentation: .named))
		}
		return news.date
	}
	
	var body: some View {
		NavigationView {
			ScrollView {
				VStack(spacing: 12) {
					if (news.imageURL != nil) {
						AsyncImage(url: URL(string: news.imageURL ?? "")) { image in
							Color.clear.overlay(
								image
									.resizable()
									.aspectRatio(contentMode: .fill)
							)
							.transition(.opacity.animation(.easeInOut(duration: 0.3)))
						} placeholder: {
							Color.black
								.opacity(0.2)
								.overlay(
									ProgressView()
										.progressViewStyle(.circular)
										.tint(.white)
								)
						}
						.background(Color(uiColor: UIColor(hex: news.tintColor ?? "000000")))
						.clipShape(
							RoundedRectangle(cornerRadius: 12, style: .continuous)
						)
						.overlay(
							LinearGradient(
								gradient: Gradient(colors: [.clear, .black.opacity(0.2)]),
								startPoint: .top,
								endPoint: .bottom
							)
						)
						.overlay(
							RoundedRectangle(cornerRadius: 12, style: .continuous)
								.stroke(Color.white.opacity(0.15), lineWidth: 2)
						)
						.frame(height: 250)
					}
					
					VStack(alignment: .leading, spacing: 16) {
						if let title = news.title {
							Text(title)
								.font(.title)
								.fontWeight(.bold)
								.lineLimit(2)
								.foregroundStyle(.primary)
								.multilineTextAlignment(.leading)
						}
						
						if let caption = news.caption {
							Text(caption)
								.font(.headline)
								.foregroundColor(.secondary)
								.multilineTextAlignment(.leading)
						}
						
						if (news.url != nil) {
							Button(action: {
								UIApplication.shared.open(news.url!)
							}) {
								Label("Open URL", systemImage: "arrow.up.right")
									.frame(maxWidth: .infinity)
							}
							.padding()
							.foregroundColor(.accentColor)
							.background(Color(uiColor: .secondarySystemBackground))
							.cornerRadius(10)
						}
						
						Text(formattedDate)
							.font(.caption)
							.foregroundColor(.secondary)
					}
					.frame(maxWidth: .infinity)
					
					Spacer()
				}
				.frame(
					minWidth: 0,
					maxWidth: .infinity,
					minHeight: 0,
					maxHeight: .infinity,
					alignment: .topLeading
				)
				.padding()
				.background(Color(uiColor: .systemBackground))
				.clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
			}
			.toolbar {
				ToolbarItem(placement: .topBarLeading) {
					Button(action: {
						dismiss()
					}) {
						Image(systemName: "chevron.left")
							.padding(10)
							.compatFontWeight(.bold)
							.background(Color(uiColor: .secondarySystemBackground))
							.clipShape(Circle())
					}
				}
			}
		}
	}
}

extension View {
	func compatFontWeight(_ _weight: Font.Weight) -> some View {
		if #available(iOS 16.0, *) {
			return self.fontWeight(_weight)
		} else {
			return self
		}
	}
}
