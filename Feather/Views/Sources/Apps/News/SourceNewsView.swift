//
//  SourceNewsView.swift
//  Feather
//
//  Created by samara on 3.05.2025.
//

import SwiftUI
import Esign

struct SourceNewsView: View {
	var news: [ASRepository.News]?
	
	var body: some View {
		if let news {
			ScrollView(.horizontal, showsIndicators: false) {
				HStack(spacing: 10) {
					ForEach(news.reversed(), id: \.id) { new in
						SourceNewsCardView(new: new)
					}
				}
				
				.padding(.horizontal)
			}
			.edgesIgnoringSafeArea(.all)
			.frame(maxWidth: .infinity)
		}
	}
}
