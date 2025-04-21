//
//  SettingsView.swift
//  Feather
//
//  Created by samara on 10.04.2025.
//

import SwiftUI

// MARK: - View
struct SettingsView: View {
	
	// MARK: Body
    var body: some View {
		FRNavigationView("Settings") {
            List {
				FRSection("Signing") {
					NavigationLink("Certificates", destination: CertificatesView())
					NavigationLink("Configuration", destination: ConfigurationView())
				}
            }
        }
    }
}
