//
//  NewsCardView.swift
//  feather
//
//  Created by samara on 3.02.2025.
//

import SwiftUI

struct NewsCardView: View {
	var news: NewsData
	
	var body: some View {
		ZStack(alignment: .bottomLeading) {
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
				
				LinearGradient(
					gradient: Gradient(colors: [.clear, .black.opacity(0.7)]),
					startPoint: .top,
					endPoint: .bottom
				)
			}
			VariableBlurView()
				.opacity(0.97)
				.frame(maxWidth: .infinity, maxHeight: .infinity)
				.rotationEffect(.degrees(180))
				.padding(.top, 95)
			
			VStack {
				Spacer()
				Text(news.title ?? "")
					.font(.headline)
					.fontWeight(.bold)
					.foregroundColor(.white)
					.lineLimit(2)
					.multilineTextAlignment(.leading)
					.padding()
			}
		}
		.frame(width: 250, height: 150)
		.background(Color(uiColor: UIColor(hex: news.tintColor ?? "000000")))
		.clipShape(
			RoundedRectangle(cornerRadius: 12, style: .continuous)
		)
		.overlay(
			RoundedRectangle(cornerRadius: 12, style: .continuous)
				.stroke(Color.white.opacity(0.15), lineWidth: 2)
		)
	}
}
