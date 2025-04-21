//
//  ConfigurationDictAddView.swift
//  Feather
//
//  Created by samara on 20.04.2025.
//

import SwiftUI

// MARK: - View
struct ConfigurationDictAddView: View {
	@Environment(\.dismiss) var dismiss
	
	@State private var newKey = ""
	@State private var newValue = ""
	@State private var showOverrideAlert = false
	
	var saveButtonDisabled: Bool {
		newKey.isEmpty || newValue.isEmpty
	}
	
	@Binding var dataDict: [String: String]
	
	// MARK: Body
    var body: some View {
		Form {
			FRSection("New") {
				TextField("Identifier", text: $newKey)
				TextField("Replacement", text: $newValue)
			}
			.autocapitalization(.none)
		}
		.toolbar {
			FRToolbarButton(
				"Save",
				systemImage: "plus",
				style: .text,
				placement: .confirmationAction,
				isDisabled: saveButtonDisabled
			) {
				dataDict[newKey] = newValue
				_clearAndDismiss()
			}
		}
    }
}

// MARK: - Extension: View
extension ConfigurationDictAddView {
	private func _clearAndDismiss() {
		newKey = ""
		newValue = ""
		dismiss()
	}
}
