//
//  NewsCardContainerView.swift
//  feather
//
//  Created by samara on 4.02.2025.
//

import SwiftUI

struct NewsCardContainerView: View {
	@Binding var isSheetPresented: Bool
	var news: NewsData
	@Namespace private var namespace
	
	let uuid = UUID().uuidString
	
    var body: some View {
		Button(action: {
			isSheetPresented = true
		}) {
			NewsCardView(news: news)
			.fullScreenCover(isPresented: $isSheetPresented) {
				CardContextMenuView(news: news)
					.compatNavigationTransition(id: uuid, ns: namespace)
			}
			.compatMatchedTransitionSource(id: uuid, ns: namespace)
			.compactContentMenuPreview(news: news)
		}
    }
}

extension View {
	func compactContentMenuPreview(news: NewsData) -> some View {
		if #available(iOS 16.0, *) {
			return self.contextMenu {
				if (news.url != nil) {
					Button(action: {
						UIApplication.shared.open(news.url!)
					}) {
						Label("Open URL", systemImage: "arrow.up.right")
					}
				}
			}
		} else {
			return self
		}
	}
}
