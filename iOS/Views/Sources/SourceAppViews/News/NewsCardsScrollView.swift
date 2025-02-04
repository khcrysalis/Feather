//
//  NewsCardsScrollView.swift
//  feather
//
//  Created by samara on 3.02.2025.
//

import SwiftUI

struct NewsCardsScrollView: View {
	@State private var newsData: [NewsData]
	
	init(newsData: [NewsData]) {
		_newsData = State(initialValue: newsData)		
	}
	
	var body: some View {
		ScrollView(.horizontal, showsIndicators: false) {
			HStack(spacing: 10) {
				ForEach(newsData.reversed(), id: \.self) { new in
					NewsCardView(news: new)
				}
			}
			.padding()
		}
		.frame(maxWidth: .infinity)
	}
}
