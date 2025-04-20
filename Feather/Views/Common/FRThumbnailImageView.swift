//
//  FRThumbnailImageView.swift
//  Feather
//
//  Created by samara on 20.04.2025.
//


import SwiftUI
import QuickLookThumbnailing

struct FRThumbnailImageView: View {
	@State private var _thumbnail: CGImage? = nil
	private let _frame: CGFloat = 45
	//
	//
	//
	let url: URL
	
	var body: some View {
		Group {
			if let thumbnail = _thumbnail {
				Image(thumbnail, scale: UIScreen.main.scale, label: Text("PDF"))
					.resizable()
					.aspectRatio(contentMode: .fit)
			} else {
				ProgressView()
					.onAppear(perform: _getThumbnail)
			}
		}
		.frame(height: _frame)
		.cornerRadius(2)
	}
	
	private func _getThumbnail() {
		let size: CGSize = CGSize(width: _frame, height: _frame)
		let request = QLThumbnailGenerator.Request(fileAt: url, size: size, scale: UIScreen.main.scale, representationTypes: .all)
		let generator = QLThumbnailGenerator.shared
		
		generator.generateRepresentations(for: request) { (thumbnail, type, error) in
			DispatchQueue.main.async {
				if let cgImage = thumbnail?.cgImage {
					self._thumbnail = cgImage
				}
			}
		}
	}
}
