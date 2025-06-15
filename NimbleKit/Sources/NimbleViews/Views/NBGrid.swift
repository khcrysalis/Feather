//
//  NBGrid.swift
//  NimbleKit
//
//  Created by samara on 10.05.2025.
//

import SwiftUI

public struct NBGrid<Content>: View where Content: View {
	private var _content: Content
	
	private var _adaptiveColumns: [GridItem] {
		[GridItem(.adaptive(minimum: 340), spacing: 16)]
	}
	
	public init(@ViewBuilder content: () -> Content) {
		self._content = content()
	}
	
	public var body: some View {
		ScrollView {
			LazyVGrid(columns: _adaptiveColumns, spacing: 16) {
				_content
			}.padding(.horizontal)
		}
	}
}
