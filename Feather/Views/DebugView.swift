//
//  DebugView.swift
//  Feather
//
//  Created by samara on 14.04.2025.
//
#if DEBUG

import SwiftUI

struct DebugView: View {
	var body: some View {
		FRNavigationView("Debug") {
			List {
				Section("This is meant to be seen on debug builds") {
					Text("Debug")
						.foregroundStyle(.secondary)
				}
				
				NavigationLink("Preview with Temporary Changes", destination: TemporarySettingsView())
			}
		}
	}
}

struct TemporarySettingsView: View {
	@StateObject private var optionsManager = OptionsManager.shared
	@State private var temporaryOptions: Options
	
	init() {
		self._temporaryOptions = State(initialValue: OptionsManager.shared.options)
	}
	
	var body: some View {
		Form {
			SigningOptionsSharedView(
				options: $temporaryOptions,
				temporaryOptions: optionsManager.options
			)
		}
		.navigationTitle("Preview Settings")
		.onReceive(optionsManager.objectWillChange) { _ in
			temporaryOptions = optionsManager.options
		}
	}
}

#endif
