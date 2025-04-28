//
//  View+compatSearchScopes.swift
//  Feather
//
//  Created by samara on 27.04.2025.
//

import SwiftUI

extension View {

	@ViewBuilder
	public func compatSearchScopes<T: Hashable, Content: View>(
		_ selection: Binding<T>,
		@ViewBuilder content: @escaping () -> Content
	) -> some View {
		if #available(iOS 16.4, *) {
			self.searchScopes(selection, activation: .onSearchPresentation, content)
		} else {
			self.searchScopes(selection, scopes: content)
		}
	}
}
