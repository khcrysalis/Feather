//
//  SigningView.swift
//  Feather
//
//  Created by samara on 14.04.2025.
//

import SwiftUI

struct SigningView: View {
	@Environment(\.dismiss) var dismiss
	@StateObject private var optionsManager = OptionsManager.shared
	@State private var temporaryOptions: Options
	
	var app: AppInfoPresentable
	
	init(app: AppInfoPresentable) {
		self.app = app
		self._temporaryOptions = State(initialValue: OptionsManager.shared.options)
	}
	
    var body: some View {
		FRNavigationView("Sign", displayMode: .inline) {
			Form {
				
			}
			.toolbar {
				FRToolbarButton(
					"Dismiss",
					systemImage: "chevron.left",
					placement: .topBarLeading
				) {
					dismiss()
				}
			}
		}
		.onReceive(optionsManager.objectWillChange) { _ in
			temporaryOptions = optionsManager.options
		}
    }
}
