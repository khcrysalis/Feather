//
//  SigningTweaksView.swift
//  Feather
//
//  Created by samara on 20.04.2025.
//

import SwiftUI
import NimbleViews

// MARK: - View
struct SigningTweaksView: View {
	@State private var _isAddingPresenting = false
	
	@Binding var options: Options
	
	// MARK: Body
	var body: some View {
		NBList(.localized("Tweaks")) {
			NBSection(.localized("Injection")) {
				SigningOptionsView.picker(
					"Injection Path",
					systemImage: "doc.badge.gearshape",
					selection: $options.injectPath,
					values: Options.injectPathValues,
					id: \.description
				)
				SigningOptionsView.picker(
					"Injection Folder",
					systemImage: "folder.badge.gearshape",
					selection: $options.injectFolder,
					values: Options.injectFolderValues,
					id: \.description
				)
			}
			
			NBSection(.localized("Tweaks")) {
				if !options.injectionFiles.isEmpty {
					ForEach(options.injectionFiles, id: \.absoluteString) { tweak in
						_file(tweak: tweak)
					}
				} else {
					Text(verbatim: "No files chosen.")
						.font(.footnote)
						.foregroundColor(.disabled())
				}
			}
		}
		.toolbar {
			NBToolbarButton(
				systemImage: "plus",
				style: .icon,
				placement: .topBarTrailing
			) {
				_isAddingPresenting = true
			}
		}
		.sheet(isPresented: $_isAddingPresenting) {
			FileImporterRepresentableView(
				allowedContentTypes: [.dylib, .deb],
				onDocumentsPicked: { urls in
					guard let selectedFileURL = urls.first else { return }
					
					FileManager.default.moveAndStore(selectedFileURL, with: "FeatherTweak") { url in
						options.injectionFiles.append(url)
					}
				}
			)
		}
		.animation(.smooth, value: options.injectionFiles)
	}
}

// MARK: - Extension: View
extension SigningTweaksView {
	@ViewBuilder
	private func _file(tweak: URL) -> some View {
		Label(tweak.lastPathComponent, systemImage: "folder")
			.lineLimit(2)
			.frame(maxWidth: .infinity, alignment: .leading)
			.swipeActions(edge: .trailing, allowsFullSwipe: true) {
				Button(role: .destructive) {
					FileManager.default.deleteStored(tweak) { url in
						if let index = options.injectionFiles.firstIndex(where: { $0 == url }) {
							options.injectionFiles.remove(at: index)
						}
					}
				} label: {
					Label(.localized("Delete"), systemImage: "trash")
				}
			}
	}
}
