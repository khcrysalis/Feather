//
//  SourceNewsView.swift
//  Feather
//
//  Created by samara on 3.05.2025.
//

import SwiftUI
import AltSourceKit

struct SourceNewsView: View {
	@State var isLoading = true
	@State var hasLoadedInitialData = false
	
	var news: [ASRepository.News]?
	
	var body: some View {
		VStack {
			if
				let news,
				!news.isEmpty
			{
				ScrollView(.horizontal, showsIndicators: false) {
					LazyHStack(spacing: 10) {
						ForEach(news.reversed(), id: \.id) { new in
							SourceNewsCardView(new: new)
						}
					}
					.padding(.horizontal, 21)
				}
				.frame(height: 150)
				.opacity(isLoading ? 0 : 1)
				.transition(.opacity)
			}
		}
		.frame(height: (news?.isEmpty == false) ? 150 : 0)
		.onAppear {
			if !hasLoadedInitialData && news?.isEmpty == false {
				_load()
				hasLoadedInitialData = true
			}
		}
	}
	
	private func _load() {
		withAnimation(.easeIn(duration: 0.3)) {
			isLoading = false
		}
	}
}
