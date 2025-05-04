//
//  SourceNewsView.swift
//  Feather
//
//  Created by samara on 3.05.2025.
//

import SwiftUI
import Esign

struct SourceNewsView: View {
	@State var isLoading = false
	var news: [ASRepository.News]?
	
	var body: some View {
		VStack {
			if
				let news = news,
				!news.isEmpty
			{
				ScrollView(.horizontal, showsIndicators: false) {
					LazyHStack(spacing: 10) {
						ForEach(news.reversed(), id: \.id) { new in
							SourceNewsCardView(new: new)
						}
					}
					.padding(.horizontal)
				}
				.frame(height: 150)
				.opacity(isLoading ? 1 : 0)
				.transition(.opacity)
			}
		}
		.frame(height: (news?.isEmpty == false) ? 150 : 0)
		.onAppear {
			if news?.isEmpty == false {
				loadNewsContent()
			}
		}
	}
	
	private func loadNewsContent() {
		// short delay to ensure UI is responsive during initial render
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
			withAnimation(.easeIn(duration: 0.3)) {
				isLoading = true
			}
		}
	}
}
