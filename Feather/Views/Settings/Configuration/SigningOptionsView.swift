//
//  SigningOptionsView.swift
//  Feather
//
//  Created by samara on 15.04.2025.
//

import SwiftUI

struct SigningOptionsView: View {
	@StateObject private var optionsManager = OptionsManager.shared
	
    var body: some View {
		List {
			NavigationLink("Display Names", destination: SigningOptionsDictView(
					title: "Display Names",
					dataDict: $optionsManager.options.displayNames
				)
			)
			NavigationLink("Identifers", destination: SigningOptionsDictView(
					title: "Identifers",
					dataDict: $optionsManager.options.identifiers
				)
			)
			
			SigningOptionsSharedView(options: $optionsManager.options)
		}
		.navigationTitle("Configuration")
		.navigationBarTitleDisplayMode(.inline)
		.toolbar {
			FRToolbarMenu(
				"Random String",
				systemImage: "character.textbox",
				style: .icon,
				placement: .topBarTrailing
			) {
				Section("Random String") {
					Button("Change") {
						
					}
					Button("Export") {
						
					}
				}
			}
		}
		.onChange(of: optionsManager.options) { _ in
			optionsManager.saveOptions()
		}
    }
}
