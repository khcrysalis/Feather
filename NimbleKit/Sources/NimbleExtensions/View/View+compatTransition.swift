//
//  View+compatTransition.swift
//  NimbleKit
//
//  Created by samara on 3.05.2025.
//

import SwiftUI

extension View {
	@ViewBuilder
	public func compatTransition() -> some View {
		if #available(iOS 17.0, *) {
			self.transition(.blurReplace)
		} else {
			self.transition(AnyTransition.opacity.combined(with: .scale).combined(with: .opacity))
		}
	}
}
