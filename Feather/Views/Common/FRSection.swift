//
//  SectionProminentHeaderWrapper.swift
//  Feather
//
//  Created by samara on 11.04.2025.
//

import SwiftUI

struct FRSection<Content, Footer>: View
where 	Content: View,
		Footer: View
{
	private var _headerText: String
	private var _headerTextSecondary: String?
	private var _headerImage: Image?
	private var _content: Content
	private var _footer: Footer
	
	init(_ headerText: String,
		 secondary headerTextSecondary: String? = nil,
		 image: Image? = nil,
		 @ViewBuilder content: () -> Content,
		 @ViewBuilder footer: () -> Footer
	) {
		self._headerText = headerText
		self._headerTextSecondary = headerTextSecondary
		self._headerImage = image
		self._content = content()
		self._footer = footer()
	}
	
	init(_ headerText: String,
		 secondary headerTextSecondary: String? = nil,
		 image: Image? = nil,
		 @ViewBuilder content: () -> Content
	) where Footer == EmptyView {
		self._headerText = headerText
		self._headerTextSecondary = headerTextSecondary
		self._headerImage = image
		self._content = content()
		self._footer = EmptyView()
	}
	
	var body: some View {
		Section(
			header:
				HStack(alignment: .firstTextBaseline, spacing: 4) {
					if let _headerImage {
						_headerImage
							.resizable()
							.frame(width: 23, height: 23)
					}
					
					Text(_headerText)
						.fontWeight(.bold)
						.font(.title2)
						.foregroundStyle(.primary)
					
					if let _headerTextSecondary {
						Text(_headerTextSecondary)
							.font(.caption)
							.foregroundStyle(.secondary)
							.contentTransition(.numericText())
					}
					
					Spacer()
				},
			footer: _footer
				.font(.caption)
				.foregroundColor(.secondary)
		) {
			_content
		}
		.headerProminence(.increased)
	}
}
