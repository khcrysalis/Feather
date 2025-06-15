//
//  SigningEntitlementsView.swift
//  Feather
//
//  Created by samara on 20.04.2025.
//

import SwiftUI
import NimbleViews

// MARK: - View
struct SigningEntitlementsView: View {
	@State private var _isAddingPresenting = false
	
	@Binding var bindingValue: URL?
	
	// MARK: Body
	var body: some View {
		NBList(.localized("Entitlements")) {
			if let ent = bindingValue {
				Text(ent.lastPathComponent)
					.swipeActions() {
						Button(.localized("Delete")) {
							FileManager.default.deleteStored(ent) { _ in
								bindingValue = nil
							}
						}
					}
			} else {
				Button(.localized("Select entitlements file")) {
					_isAddingPresenting = true
				}
			}
		}
		.sheet(isPresented: $_isAddingPresenting) {
			FileImporterRepresentableView(
				allowedContentTypes:  [.xmlPropertyList, .plist, .entitlements],
				onDocumentsPicked: { urls in
					guard let selectedFileURL = urls.first else { return }
					
					FileManager.default.moveAndStore(selectedFileURL, with: "FeatherEntitlement") { url in
						bindingValue = url
					}
				}
			)
			.ignoresSafeArea()
		}
	}
}
