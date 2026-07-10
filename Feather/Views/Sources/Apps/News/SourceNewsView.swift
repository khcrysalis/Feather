//
//  SourceNewsView.swift
//  Feather
//
//  Created by samara on 3.05.2025.
//

import SwiftUI
import AltSourceKit
import NimbleViews

// MARK: - View
struct SourceNewsView: View {
	@State var isLoading = true
	@State var hasLoadedInitialData = false
	
	@State private var _selectedNewsPresenting: ASRepository.News?
	
	@Namespace private var _namespace
	
	var news: [ASRepository.News]?
	
	private var _sortedNews: [ASRepository.News] {
		guard let news else { return [] }
		return news.sorted {
			switch ($0.date, $1.date) {
			case let (lhs?, rhs?):
				return lhs > rhs
			case (.some, .none):
				return true
			case (.none, .some):
				return false
			case (.none, .none):
				return false
			}
		}
	}
	
	// MARK: Body
	var body: some View {
		VStack {
			if
				!_sortedNews.isEmpty
			{
				ScrollView(.horizontal, showsIndicators: false) {
					LazyHStack(spacing: 10) {
						ForEach(_sortedNews, id: \.id) { new in
							Button {
								_selectedNewsPresenting = new
							} label: {
								SourceNewsCardView(new: new)
									.compatMatchedTransitionSource(id: new.id, ns: _namespace)
							}
						}
					}
					.padding(.horizontal, 16)
				}
				.frame(height: 160)
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
		.fullScreenCover(item: $_selectedNewsPresenting) { new in
			SourceNewsCardInfoView(new: new)
				.compatNavigationTransition(id: new.id, ns: _namespace)
		}
	}
	
	private func _load() {
		withAnimation(.easeIn(duration: 0.3)) {
			isLoading = false
		}
	}
}
