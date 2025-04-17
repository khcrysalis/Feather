//
//  FRBottomSelectionView.swift
//  Feather
//
//  Created by samara on 16.04.2025.
//

import SwiftUI

struct FRBottomSelectionView<Content>: View where Content: View {
	private var _content: Content
	
	init(
		@ViewBuilder content: () -> Content
	) {
		self._content = content()
	}
	
    var body: some View {
		VStack(spacing: 10) {
			_content
		}
		.padding()
		.frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct FRBottomDetent: CustomPresentationDetent {
	static func height(in context: Context) -> CGFloat? {
		return max(50, context.maxDetentValue * 0.19)
	}
}
