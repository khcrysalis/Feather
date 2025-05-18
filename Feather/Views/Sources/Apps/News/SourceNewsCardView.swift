//
//  SourceNewsCardView.swift
//  Feather
//
//  Created by samara on 3.05.2025.
//

import SwiftUI
import AltSourceKit
import NukeUI

struct SourceNewsCardView: View {
	var new: ASRepository.News
	
	var body: some View {
		ZStack(alignment: .bottomLeading) {
			let placeholderView = {
				Color.gray.opacity(0.2)
			}()
			
			if let iconURL = new.imageURL {
				LazyImage(url: iconURL) { state in
					if let image = state.image {
						image
							.resizable()
							.aspectRatio(contentMode: .fill)
							.frame(width: 250, height: 150)
							.clipped()
					} else {
						placeholderView
					}
				}
			} else {
				placeholderView
			}
			
			LinearGradient(
				gradient: Gradient(colors: [.black.opacity(0.6), .clear]),
				startPoint: .bottom,
				endPoint: .top
			)
			.frame(height: 70)
			.frame(maxWidth: .infinity, alignment: .bottom)
			.clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
			
			Text(new.title)
				.font(.headline)
				.foregroundColor(.white)
				.lineLimit(2)
				.padding()
		}
		.frame(width: 250, height: 150)
		.background(new.tintColor ?? Color.secondary)
		.clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
		.overlay(
			RoundedRectangle(cornerRadius: 12, style: .continuous)
				.strokeBorder(Color.gray.opacity(0.2), lineWidth: 1)
		)
	}
}

