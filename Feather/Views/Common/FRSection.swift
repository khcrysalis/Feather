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
	private var headerText: String
	private var headerImage: Image?
	private var content: Content
	private var footer: Footer
	
	init(_ headerText: String,
		 image: Image? = nil,
		 @ViewBuilder content: () -> Content,
		 @ViewBuilder footer: () -> Footer
	) {
		self.headerText = headerText
		self.headerImage = image
		self.content = content()
		self.footer = footer()
	}
	
	init(_ headerText: String,
		 image: Image? = nil,
		 @ViewBuilder content: () -> Content
	) where Footer == EmptyView {
		self.headerText = headerText
		self.headerImage = image
		self.content = content()
		self.footer = EmptyView()
	}
	
	var body: some View {
		Section(
			header: HStack(spacing: 8) {
				if let imageName = headerImage {
					imageName
						.resizable()
						.frame(width: 23, height: 23)
				}
				
				Text(headerText)
					.fontWeight(.bold)
					.font(.title2)
					.foregroundStyle(.primary)
				
				Spacer()
			},
			footer: footer
				.font(.caption)
				.foregroundColor(.secondary)
		) {
			content
		}
		.headerProminence(.increased)
	}
}
