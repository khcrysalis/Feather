//
//  SectionProminentHeaderWrapper.swift
//  Feather
//
//  Created by samara on 11.04.2025.
//

import SwiftUI

struct FRSection<Content>: View where Content: View {
	private var headerText: String
	private var headerImage: Image?
	private var content: Content
	
	init(_ headerText: String,
		 image: Image? = nil,
		 @ViewBuilder content: () -> Content) {
		self.headerText = headerText
		self.headerImage = image
		self.content = content()
	}
	
	var body: some View {
		Section(header:
			HStack(spacing: 8) {
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
			}
		) {
			content
		}
		.headerProminence(.increased)
	}
}
