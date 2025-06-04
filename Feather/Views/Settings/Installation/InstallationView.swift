//
//  InstallationView.swift
//  Feather
//
//  Created by samara on 3.06.2025.
//

import SwiftUI
import NimbleViews

struct InstallationView: View {
	@AppStorage("Feather.installationMethod") private var _installationMethod: Int = 0
	
	private let _installationMethods: [String] = [
		.localized("Server"),
		.localized("idevice")
	]
	
    var body: some View {
		NBList(.localized("Installation")) { // localize
			Section {
				Picker(.localized("Installation Type"), systemImage: "arrow.down.app", selection: $_installationMethod) {
					ForEach(_installationMethods.indices, id: \.description) { index in
						Text(_installationMethods[index]).tag(index)
					}
				}
			}
			
			Section {
				NavigationLink(.localized("Server & SSL"), destination: ServerView())
					.disabled(_installationMethod != 0)
				NavigationLink(.localized("Tunnel & Pairing"), destination: TunnelView())
					.disabled(_installationMethod != 1)
			}
		}
    }
}
