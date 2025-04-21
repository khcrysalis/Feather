//
//  SigningAppPropertiesView.swift
//  Feather
//
//  Created by samara on 17.04.2025.
//

import SwiftUI

// MARK: - View
struct SigningPropertiesView: View {
	@Environment(\.dismiss) var dismiss
	
	@State private var text: String = ""
	
	var title: String
	var initialValue: String 
	@Binding var bindingValue: String?
	
	// MARK: Body
	var body: some View {
		Form {
			TextField(initialValue, text: $text)
				.textInputAutocapitalization(.none)
		}
		.navigationTitle(title)
		.toolbar {
			FRToolbarButton(
				"Save",
				systemImage: "checkmark",
				style: .text,
				placement: .topBarTrailing,
				isDisabled: text.isEmpty
			) {
				bindingValue = text
				dismiss()
			}
		}
	}
}
