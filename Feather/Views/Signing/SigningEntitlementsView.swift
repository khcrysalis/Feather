//
//  SigningEntitlementsView.swift
//  Feather
//
//  Created by samara on 20.04.2025.
//

import SwiftUI

// MARK: - View
struct SigningEntitlementsView: View {
	@State private var isAddingEnt = false
	
	@Binding var bindingValue: URL?
	
	// MARK: Body
	var body: some View {
		Form {
			if let ent = bindingValue {
				Text(ent.lastPathComponent)
					.swipeActions() { Button("Delete") {
						_deleteFile(at: ent)
					}}
			} else {
				Button(action: {
					isAddingEnt = true
				}, label: {
					Text("Select entitlements file")
				})
			}
		}
		.navigationTitle("Entitlements")
		.fileImporter(
			isPresented: $isAddingEnt,
			allowedContentTypes: [.xmlPropertyList, .plist, .entitlements]
		) { result in
			if case .success(let file) = result {
				_moveEnt(file)
			}
		}
	}
}

// MARK: - Extension: View
extension SigningEntitlementsView {
	private func _deleteFile(at url: URL) {
		bindingValue = nil
		
		do {
			try? FileManager.default.removeItem(at: url)
		}
	}
}

// MARK: - Extension: View (import)
extension SigningEntitlementsView {
#warning("this can be improved")
	private func _moveEnt(_ url: URL) {
		guard url.startAccessingSecurityScopedResource() else {
			return
		}
		let fileManager = FileManager.default
		let tempDir = fileManager.temporaryDirectory
			.appendingPathComponent("FeatherEntitlement_\(UUID().uuidString)", isDirectory: true)
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
				
				bindingValue = destinationUrl
			}
		}
	}
}
