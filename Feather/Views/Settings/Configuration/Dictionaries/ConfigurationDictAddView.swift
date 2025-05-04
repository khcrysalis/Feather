//
//  ConfigurationDictAddView.swift
//  Feather
//
//  Created by samara on 20.04.2025.
//

import SwiftUI
import NimbleViews

// MARK: - View
struct ConfigurationDictAddView: View {
	@Environment(\.dismiss) var dismiss
	
	@State private var _newKey = ""
	@State private var _newValue = ""
	@State private var _showOverrideAlert = false
	
	var saveButtonDisabled: Bool {
		_newKey.isEmpty || _newValue.isEmpty
	}
	
	@Binding var dataDict: [String: String]
	
	// MARK: Body
    var body: some View {
		Form {
			NBSection("New") {
				TextField("Identifier", text: $_newKey)
				TextField("Replacement", text: $_newValue)
			}
			.autocapitalization(.none)
		}
		.toolbar {
			NBToolbarButton(
				"Save",
				systemImage: "plus",
				style: .text,
				placement: .confirmationAction,
				isDisabled: saveButtonDisabled
			) {
				dataDict[_newKey] = _newValue
				dismiss()
			}
		}
    }
}
