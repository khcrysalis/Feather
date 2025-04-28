//
//  View+NavTransition.swift
//  Luce
//
//  Created by samara on 30.01.2025.
//

import SwiftUI

extension View {
	@ViewBuilder
	public func compatNavigationTransition(id: String, ns: Namespace.ID) -> some View {
		if #available(iOS 18.0, *) {
			self.navigationTransition(.zoom(sourceID: id, in: ns))
		} else {
			self
		}
	}
	
	@ViewBuilder
	public func compatMatchedTransitionSource(id: String, ns: Namespace.ID) -> some View {
		if #available(iOS 18.0, *) {
			self.matchedTransitionSource(id: id, in: ns)
		} else {
			self
		}
	}
}
