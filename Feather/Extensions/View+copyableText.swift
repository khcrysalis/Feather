//
//  View+copyable.swift
//  Feather
//
//  Created by samara on 5.06.2025.
//

import SwiftUI

extension View {
	func copyableText(_ textToCopy: String) -> some View {
		self.contextMenu {
			Button(action: {
				UIPasteboard.general.string = textToCopy
			}) {
				Label(.localized("Copy"), systemImage: "doc.on.doc")
			}
		}
	}
}
