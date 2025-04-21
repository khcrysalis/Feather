//
//  SigningTweaksView.swift
//  Feather
//
//  Created by samara on 20.04.2025.
//

import SwiftUI

// MARK: - View
struct SigningTweaksView: View {
	@State private var isAddingTweak = false
	
	@Binding var options: Options
	
	// MARK: Body
	var body: some View {
		List(options.injectionFiles, id: \.absoluteString) { tweak in
			_file(tweak: tweak)
		}
		.animation(.smooth, value: options.injectionFiles)
		.listStyle(.plain)
		.toolbar {
			FRToolbarButton(
				"Add",
				systemImage: "plus",
				style: .icon,
				placement: .topBarTrailing
			) {
				isAddingTweak = true
			}
		}
		.fileImporter(
			isPresented: $isAddingTweak,
			allowedContentTypes: [.dylib, .deb]
		) { result in
			if case .success(let file) = result {
				_moveTweak(file)
			}
		}
		.navigationTitle("Tweaks")
	}
	
	#warning("this can be improved")
	private func _moveTweak(_ url: URL) {
		guard url.startAccessingSecurityScopedResource() else {
			return
		}
		
		let fileManager = FileManager.default
		let tempDir = fileManager.temporaryDirectory
			.appendingPathComponent("FeatherTweak_\(UUID().uuidString)", isDirectory: true)
		let destinationUrl = tempDir.appendingPathComponent(url.lastPathComponent)
		
		Task {
			defer {
				url.stopAccessingSecurityScopedResource()
			}
			
			do {
				if !fileManager.fileExists(atPath: tempDir.path) {
					try fileManager.createDirectory(at: tempDir, withIntermediateDirectories: true)
				}
								
				try fileManager.copyItem(at: url, to: destinationUrl)
				
				options.injectionFiles.append(destinationUrl)
			}
		}
	}
}

// MARK: - Extension: View
extension SigningTweaksView {
	@ViewBuilder
	private func _file(tweak: URL) -> some View {
		HStack(spacing: 12) {
			FRThumbnailImageView(url: tweak)
			Text(tweak.lastPathComponent)
				.lineLimit(2)
		}
		.frame(maxWidth: .infinity, alignment: .leading)
		.swipeActions(edge: .trailing, allowsFullSwipe: true) {
			Button(role: .destructive) {
				_deleteFile(at: tweak)
			} label: {
				Label("Delete", systemImage: "trash")
			}
		}
	}
	
	private func _deleteFile(at url: URL) {
		if let index = options.injectionFiles.firstIndex(where: { $0 == url }) {
			options.injectionFiles.remove(at: index)
		}
		
		do {
			try? FileManager.default.removeItem(at: url)
		}
	}
}
