//
//  NewsCardsScrollView.swift
//  feather
//
//  Created by samara on 3.02.2025.
//

import SwiftUI

struct NewsCardsScrollView: View {
	@State private var newsData: [NewsData]
	@State private var sheetStates: [String: Bool] = [:]
	@State var isSheetPresented = false
	
	init(newsData: [NewsData]) {
		_newsData = State(initialValue: newsData)
		print(newsData)
	}
	
	var body: some View {
		ScrollView(.horizontal, showsIndicators: false) {
			HStack(spacing: 10) {
				ForEach(newsData.reversed(), id: \.self) { new in
					let binding = Binding(
						get: { sheetStates[new.identifier] ?? false },
						set: { sheetStates[new.identifier] = $0 }
					)
					
					NewsCardContainerView(isSheetPresented: binding, news: new)
				}
			}
			.padding()
		}
		.frame(maxWidth: .infinity)
	}
}
