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
				HStack(alignment: .center, spacing: 4) {
					if let _systemName {
						Image(systemName: _systemName)
							.font(.system(size: 12))
							.offset(y: -2)
					}
					
					Text(_headerText)
						.fontWeight(.bold)
						.font(.title2)
						.foregroundStyle(.primary)
						
					
                    Spacer()
                    
					if let _headerTextSecondary {
                        if #available(iOS 26.0, *) {
                            Text(_headerTextSecondary)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .contentTransition(.numericText())
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4.4)
                                .background(Color(uiColor: .quaternarySystemFill))
                                .clipShape(Capsule())
                                .glassEffect()
                        } else {
                            Text(_headerTextSecondary)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .contentTransition(.numericText())
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4.4)
                                .background(Color(uiColor: .quaternarySystemFill))
                                .clipShape(Capsule())
                        }
					}
				}
				.offset(y: 2)
			,
			footer: _footer
				.font(.caption)
				.foregroundColor(.secondary)
		) {
			_content
		}
		.headerProminence(.increased)
	}
}
