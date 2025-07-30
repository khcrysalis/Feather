//
//  FlexibleHeader.swift
//  Feather
//
//  Created by samsam on 7/25/25.
//

import SwiftUI

@available(iOS 18.0, *)
@Observable private class FlexibleHeaderGeometry {
	var offset: CGFloat = 0
	var windowHeight: CGFloat = 0
}

/// A view modifier that stretches content when the containing geometry offset changes.
@available(iOS 18.0, *)
private struct FlexibleHeaderContentModifier: ViewModifier {
	@Environment(FlexibleHeaderGeometry.self) private var geometry

	func body(content: Content) -> some View {
		let height = (geometry.windowHeight / 3.2) - geometry.offset
		content
			.frame(height: height)
			.padding(.bottom, geometry.offset)
			.offset(y: geometry.offset)
	}
}

/// A view modifier that tracks scroll geometry and window size to update header behavior.
@available(iOS 18.0, *)
private struct FlexibleHeaderScrollViewModifier: ViewModifier {
	@State private var geometry = FlexibleHeaderGeometry()

	func body(content: Content) -> some View {
		content
			.onScrollGeometryChange(for: CGFloat.self) { geometry in
				min(geometry.contentOffset.y + geometry.contentInsets.top, 0)
			} action: { _, offset in
				geometry.offset = offset
			}
			.onGeometryChange(for: CGSize.self) { geometry in
				geometry.size
			} action: {
				geometry.windowHeight = $0.height
			}
			.environment(geometry)
	}
}

// MARK: - View Extensions

extension ScrollView {
	@ViewBuilder
	@MainActor func flexibleHeaderScrollView() -> some View {
		if #available(iOS 18, *) {
			modifier(FlexibleHeaderScrollViewModifier())
		} else {
			self
		}
	}
}

extension View {
	@ViewBuilder
	func flexibleHeaderContent() -> some View {
		if #available(iOS 18, *) {
			modifier(FlexibleHeaderContentModifier())
		} else {
			self
		}
	}
	
	@ViewBuilder
	func shouldSetInset() -> some View {
		if #available(iOS 18, *) {
			self.ignoresSafeArea(edges: .top)
		} else {
			self
		}
	}
}
