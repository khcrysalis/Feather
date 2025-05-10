//
//  NBListAdaptable.swift
//  NimbleKit
//
//  Created by samara on 7.05.2025.
//

import SwiftUI

public struct NBListAdaptable<Content>: View where Content: View {
	@Environment(\.horizontalSizeClass) private var horizontalSizeClass
	
	private var _content: Content
	
	public init(@ViewBuilder content: () -> Content) {
		self._content = content()
	}
	
	private var _adaptiveColumns: [GridItem] {
		[GridItem(.adaptive(minimum: 340), spacing: 16)]
	}
	
	public var body: some View {
		if horizontalSizeClass == .compact {
			List {
				_content
			}
			.listStyle(.plain)
		} else {
			ScrollView {
				LazyVGrid(columns: _adaptiveColumns, spacing: 16) {
					_content
				}
				.padding()
			}
		}
	}
}
