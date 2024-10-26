//
//  IdentifiersView.swift
//  feather
//
//  Created by samara on 25.10.2024.
//

import SwiftUI

struct IdentifiersView: View {
	@ObservedObject var signingDataWrapper: SigningDataWrapper
	@State private var showAddFields = false
	@State private var newIdentifier: String = ""
	@State private var newReplacement: String = ""
	
	init(signingDataWrapper: SigningDataWrapper) {
		self.signingDataWrapper = signingDataWrapper
	}
	
	var body: some View {
		List {
			Section {
				Button(action: {
						showAddFields.toggle()
				}) {
					Text("Add Identifier")
				}
				
				if showAddFields {
					TextField("New Replacement Identifier", text: $newIdentifier)
					TextField("Replacement", text: $newReplacement)
					
					Button("Add") { addNewIdentifier() }.disabled(newIdentifier.isEmpty || newReplacement.isEmpty)
				}
			}
			
			Section {
				ForEach(signingDataWrapper.signingOptions.bundleIdConfig.keys.sorted(), id: \.self) { key in
					Text(key)
						.fontWeight(.bold)
					TextField("Identifier", text: Binding(
						get: { signingDataWrapper.signingOptions.bundleIdConfig[key] ?? "" },
						set: { signingDataWrapper.signingOptions.bundleIdConfig[key] = $0 }
					))
					.foregroundColor(.secondary)
				}
				.onDelete(perform: deleteIdentifiers)
			}
		}
		.navigationTitle("Identifiers")
		.navigationBarTitleDisplayMode(.inline)
	}
	
	private func addNewIdentifier() {
		// Add the new identifier and reset the fields
		if !newIdentifier.isEmpty && !newReplacement.isEmpty {
			signingDataWrapper.signingOptions.bundleIdConfig[newIdentifier] = newReplacement
			newIdentifier = ""
			newReplacement = ""
			showAddFields = false
		}
	}

	private func deleteIdentifiers(at offsets: IndexSet) {
		for index in offsets {
			let key = signingDataWrapper.signingOptions.bundleIdConfig.keys.sorted()[index]
			signingDataWrapper.signingOptions.bundleIdConfig.removeValue(forKey: key)
		}
	}
}

