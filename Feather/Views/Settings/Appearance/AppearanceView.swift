//
//  AppearanceView.swift
//  Feather
//
//  Created by samara on 7.05.2025.
//

import SwiftUI
import NimbleViews

struct AppearanceView: View {
	@AppStorage("Feather.libraryCellAppearance") private var _libraryCellAppearance: Int = 0
	private let _libraryCellAppearanceMethods = ["Standard", "Expiration Pill"]
	
	@AppStorage("Feather.storeCellAppearance") private var _storeCellAppearance: Int = 0
	private let _storeCellAppearanceMethods = ["Standard", "Big Description"]
	
    var body: some View {
		NBList("Appearance") {
			NBSection("Library") {
				_libraryPreview()
				Picker("Library Cell Appearance", selection: $_libraryCellAppearance) {
					ForEach(_libraryCellAppearanceMethods.indices, id: \.description) { index in
						Text(_libraryCellAppearanceMethods[index]).tag(index)
					}
				}
				.pickerStyle(.inline)
				.labelsHidden()
			}
			
			NBSection("Store") {
				Picker("Store Cell Appearance", selection: $_storeCellAppearance) {
					ForEach(_storeCellAppearanceMethods.indices, id: \.description) { index in
						Text(_storeCellAppearanceMethods[index]).tag(index)
					}
				}
				.pickerStyle(.inline)
			}
		}
    }
	
	@ViewBuilder
	private func _libraryPreview() -> some View {
		HStack(spacing: 9) {
			Image(uiImage: (UIImage(named: Bundle.main.iconFileName ?? ""))! )
				.appIconStyle(size: 57, cornerRadius: 14)
			
			NBTitleWithSubtitleView(
				title: Bundle.main.name,
				subtitle: "\(Bundle.main.version) • \(Bundle.main.bundleIdentifier ?? "")",
				linelimit: 0
			)
			
			FRExpirationPillView(
				title: "Install",
				showOverlay: _libraryCellAppearance == 0,
				expiration: Date.now.expirationInfo()
			).animation(.spring, value: _libraryCellAppearance)
		}
	}
}
