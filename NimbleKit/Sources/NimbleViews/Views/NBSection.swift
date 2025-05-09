//
//  SectionProminentHeaderWrapper.swift
//  Feather
//
//  Created by samara on 11.04.2025.
//

import SwiftUI

public struct NBSection<Content, Footer>: View
where 	Content: View,
		Footer: View
{
	private var _headerText: String
	private var _headerTextSecondary: String?
	private var _systemName: String?
	private var _content: Content
	private var _footer: Footer
	
	public init(_ headerText: String,
		 secondary headerTextSecondary: String? = nil,
			systemName: String? = nil,
		 @ViewBuilder content: () -> Content,
		 @ViewBuilder footer: () -> Footer
	) {
		self._headerText = headerText
		self._headerTextSecondary = headerTextSecondary
		self._systemName = systemName
		self._content = content()
		self._footer = footer()
	}
	
	public init(_ headerText: String,
		 secondary headerTextSecondary: String? = nil,
		 systemName: String? = nil,
		 @ViewBuilder content: () -> Content
	) where Footer == EmptyView {
		self._headerText = headerText
		self._headerTextSecondary = headerTextSecondary
		self._systemName = systemName
		self._content = content()
		self._footer = EmptyView()
	}
	
	public var body: some View {
		Section(
			header:
				HStack(alignment: .firstTextBaseline, spacing: 4) {
					if let _systemName {
						Image(systemName: _systemName)
							.font(.system(size: 12))
							.offset(y: -2)
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
