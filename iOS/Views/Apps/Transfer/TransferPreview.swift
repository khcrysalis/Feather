//
//  TransferPreview.swift
//  feather
//
//  Created by samara on 8/16/24.
//

import SwiftUI

struct TransferPreview: View {
	@State private var bounce = false
	@State private var progress: Double = 0.0
	@State private var opacity: Double = 1.0
	@State private var imageName = "archivebox.fill"
	@State private var displayText = "Packaging..."

	@State private var showNewContent = false
	
	let bounceDuration: Double = 0.8
	let opacityChangeDuration: Double = 0.7
	let progressUpdateDuration: Double = 0.7

	var body: some View {
		VStack {
			Spacer()
			VStack(spacing: 18) {
				Image(systemName: imageName)
					.antialiased(true)
					.resizable()
					.cornerRadius(8)
					.frame(width: 42, height: 42, alignment: .center)
					.scaleEffect(bounce ? 1.0 : 0.9)
					.shadow(color: .primary.opacity(0.5), radius: 10, x: 0, y: 0)
					.opacity(opacity)
					.onAppear {
						withAnimation(Animation.easeInOut(duration: bounceDuration).repeatForever(autoreverses: true)) {
							bounce.toggle()
						}
						
						withAnimation(Animation.easeInOut(duration: opacityChangeDuration).delay(1)) {
							opacity = 0.0
							imageName = "paperplane.fill"
							displayText = "Retrieving..."
						}
						
						withAnimation(Animation.easeInOut(duration: opacityChangeDuration).delay(1 + opacityChangeDuration)) {
							opacity = 1.0
						}
					}
			}
			.padding()
			Spacer()
			Text(displayText)
				.font(.system(.body, design: .rounded))
				.bold()
				.padding(.leading)
				.frame(maxWidth: .infinity, alignment: .leading)
			ProgressView(value: progress, total: 1.0)
				.progressViewStyle(LinearProgressViewStyle(tint: .accentColor))
				.padding(.bottom)
				.padding(.leading)
				.padding(.trailing)
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
		.background(Color(UIColor.quaternarySystemFill))
		.cornerRadius(12)
		.padding()
	}
}
