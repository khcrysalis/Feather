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
	
	private let _libraryCellAppearanceMethods: [String] = [
		.localized("Standard"),
		.localized("Pill")
	]
	
	@AppStorage("Feather.storeCellAppearance") private var _storeCellAppearance: Int = 0
	
	private let _storeCellAppearanceMethods: [String] = [
		.localized("Standard"),
		.localized("Big Description")
	]
	
    var body: some View {
		NBList(.localized("Appearance")) {
			NBSection(.localized("Library")) {
				_libraryPreview()
				Picker(.localized("Library Cell Appearance"), selection: $_libraryCellAppearance) {
					ForEach(_libraryCellAppearanceMethods.indices, id: \.description) { index in
						Text(_libraryCellAppearanceMethods[index]).tag(index)
					}
				}
				.pickerStyle(.inline)
				.labelsHidden()
			}
			
			NBSection(.localized("Sources")) {
                _storePreview()
				Picker(.localized("Store Cell Appearance"), selection: $_storeCellAppearance) {
					ForEach(_storeCellAppearanceMethods.indices, id: \.description) { index in
						Text(_storeCellAppearanceMethods[index]).tag(index)
					}
				}
				.pickerStyle(.inline)
                .labelsHidden()
			}
		}
    }
	
	@ViewBuilder
	private func _libraryPreview() -> some View {
		HStack(spacing: 9) {
			Image(uiImage: (UIImage(named: Bundle.main.iconFileName ?? ""))! )
				.appIconStyle(size: 57)
			
			NBTitleWithSubtitleView(
				title: Bundle.main.name,
				subtitle: "\(Bundle.main.version) • \(Bundle.main.bundleIdentifier ?? "")",
				linelimit: 0
			)
			
			FRExpirationPillView(
				title: .localized("Install"),
				showOverlay: _libraryCellAppearance == 0,
				expiration: Date.now.expirationInfo()
			).animation(.spring, value: _libraryCellAppearance)
		}
	}
    
    @ViewBuilder
    private func _storePreview() -> some View {
        VStack {
            HStack(spacing: 9) {
                Image(uiImage: (UIImage(named: Bundle.main.iconFileName ?? ""))! )
                    .appIconStyle(size: 57)
                
                NBTitleWithSubtitleView(
                    title: Bundle.main.name,
                    subtitle: "\(Bundle.main.version) • " + .localized("An awesome application"),
                    linelimit: 0
                )
            }
            
            if _storeCellAppearance != 0 {
                Text(.localized("An awesome application"))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(18)
                    .padding(.top, 2)
            }
        }
        .animation(.spring, value: _storeCellAppearance)
    }
}
