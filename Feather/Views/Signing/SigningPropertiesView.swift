//
//  SigningAppPropertiesView.swift
//  Feather
//
//  Created by samara on 17.04.2025.
//

import SwiftUI

struct SigningPropertiesView: View {
	@Environment(\.dismiss) var dismiss
	
	var title: String
	var initialValue: String 
	@Binding var bindingValue: String?
	
	@State private var text: String = ""
	
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
