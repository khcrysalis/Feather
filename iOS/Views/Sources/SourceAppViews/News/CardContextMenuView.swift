//
//  CardContextMenuView.swift
//  feather
//
//  Created by samara on 4.02.2025.
//

import SwiftUI

struct CardContextMenuView: View {
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
		VStack(alignment: .leading, spacing: 12) {
			AsyncImage(url: URL(string: news.imageURL ?? "")) { image in
				image.resizable()
					.aspectRatio(contentMode: .fill)
			} placeholder: {
				Color.gray
			}
			.frame(width: 280, height: 160)
			.clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
			.overlay(
				LinearGradient(
					gradient: Gradient(colors: [.clear, .black.opacity(0.2)]),
					startPoint: .top,
					endPoint: .bottom
				)
			)
			
			VStack(alignment: .leading, spacing: 8) {
				Text(news.title)
					.font(.title3)
					.fontWeight(.bold)
					.lineLimit(2)
				
				if let caption = news.caption {
					Text(caption)
						.font(.subheadline)
						.foregroundColor(.secondary)
						.lineLimit(2)
				}
				
				Text(formattedDate)
					.font(.caption)
					.foregroundColor(.secondary)
			}
		}
		.frame(width: 280)
		.padding()
		.background(Color(uiColor: .systemBackground))
		.clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
	}
}
