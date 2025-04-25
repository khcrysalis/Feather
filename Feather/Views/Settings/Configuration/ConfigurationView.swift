//
//  SigningOptionsView.swift
//  Feather
//
//  Created by samara on 15.04.2025.
//

import SwiftUI

// MARK: - View
struct ConfigurationView: View {
	@StateObject private var _optionsManager = OptionsManager.shared
	@State var isRandomAlertPresenting = false
	@State var randomString = ""
	
	// MARK: Body
    var body: some View {
		List {
			NavigationLink("Display Names", destination: ConfigurationDictView(
					title: "Display Names",
					dataDict: $_optionsManager.options.displayNames
				)
			)
			NavigationLink("Identifers", destination: ConfigurationDictView(
					title: "Identifers",
					dataDict: $_optionsManager.options.identifiers
				)
			)
			
			SigningOptionsView(options: $_optionsManager.options)
		}
		.navigationTitle("Configuration")
		.navigationBarTitleDisplayMode(.inline)
		.toolbar {
			FRToolbarMenu(
				_optionsManager.options.ppqString,
				systemImage: "character.textbox",
				style: .icon,
				placement: .topBarTrailing
			) {
				_randomMenuItem()
			}
		}
		.alert(_optionsManager.options.ppqString, isPresented: $isRandomAlertPresenting) {
			_randomMenuAlert()
		}
		.onChange(of: _optionsManager.options) { _ in
			_optionsManager.saveOptions()
		}
    }
}

// MARK: - Extension: View
extension ConfigurationView {
	@ViewBuilder
	private func _randomMenuItem() -> some View {
		Section(_optionsManager.options.ppqString) {
			Button("Change") {
				isRandomAlertPresenting = true
			}
			Button("Copy") {
				UIPasteboard.general.string = _optionsManager.options.ppqString
			}
		}
	}
	
	@ViewBuilder
	private func _randomMenuAlert() -> some View {
		TextField("String", text: $randomString)
		Button("Save") {
			if !randomString.isEmpty {
				_optionsManager.options.ppqString = randomString
			}
		}
		
		Button("Cancel", role: .cancel) {}
	}
}
