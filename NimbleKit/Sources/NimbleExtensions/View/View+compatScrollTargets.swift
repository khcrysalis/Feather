//
//  View+compatScrollTargets.swift
//  NimbleKit
//
//  Created by samsam on 7/30/25.
//

import SwiftUI

extension View {
	@ViewBuilder
	public func compatScrollTargetLayout() -> some View {
		if #available(iOS 17.0, *) {
			self.scrollTargetLayout()
		} else {
			self
		}
	}
	
	@ViewBuilder
	public func compatScrollTargetBehavior() -> some View {
		if #available(iOS 17.0, *) {
			self.scrollTargetBehavior(.viewAligned)
		} else {
			self
		}
	}
}
