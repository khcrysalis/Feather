//
//  SigningOptionsView.swift
//  Feather
//
//  Created by samara on 15.04.2025.
//

import SwiftUI

// MARK: - View
struct ConfigurationView: View {
	@StateObject private var optionsManager = OptionsManager.shared
	@State var isRandomAlertPresenting = false
	@State var randomString = ""
	
	// MARK: Body
    var body: some View {
		List {
			NavigationLink("Display Names", destination: ConfigurationDictView(
					title: "Display Names",
					dataDict: $optionsManager.options.displayNames
				)
			)
			NavigationLink("Identifers", destination: ConfigurationDictView(
					title: "Identifers",
					dataDict: $optionsManager.options.identifiers
				)
			)
			
			SigningOptionsView(options: $optionsManager.options)
		}
		.navigationTitle("Configuration")
		.navigationBarTitleDisplayMode(.inline)
		.toolbar {
			FRToolbarMenu(
				optionsManager.options.ppqString,
				systemImage: "character.textbox",
				style: .icon,
				placement: .topBarTrailing
			) {
				_randomMenuItem()
			}
		}
		.alert(optionsManager.options.ppqString, isPresented: $isRandomAlertPresenting) {
			_randomMenuAlert()
		}
		.onChange(of: optionsManager.options) { _ in
			optionsManager.saveOptions()
		}
    }
}

// MARK: - Extension: View
extension ConfigurationView {
	@ViewBuilder
	private func _randomMenuItem() -> some View {
		Section(optionsManager.options.ppqString) {
			Button("Change") {
				isRandomAlertPresenting = true
			}
			Button("Copy") {
				UIPasteboard.general.string = optionsManager.options.ppqString
			}
		}
	}
	
	@ViewBuilder
	private func _randomMenuAlert() -> some View {
		TextField("String", text: $randomString)
		Button("Save") {
			if !randomString.isEmpty {
				optionsManager.options.ppqString = randomString
			}
		}
		
		Button("Cancel", role: .cancel) {}
	}
}
