//
//  SigningView.swift
//  Feather
//
//  Created by samara on 14.04.2025.
//

import SwiftUI

struct SigningView: View {
	@StateObject private var optionsManager = OptionsManager.shared
	@State private var temporaryOptions: Options
	
	init() {
		self._temporaryOptions = State(initialValue: OptionsManager.shared.options)
	}
	
    var body: some View {
		FRNavigationView("Sign") {
			Form {
				
			}
		}
		.onReceive(optionsManager.objectWillChange) { _ in
			temporaryOptions = optionsManager.options
		}
    }
}
