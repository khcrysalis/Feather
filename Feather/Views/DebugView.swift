//
//  DebugView.swift
//  Feather
//
//  Created by samara on 14.04.2025.
//
#if DEBUG

import SwiftUI

struct DebugView: View {
	@AppStorage("feather.selectedCert") private var selectedCert: Int = 0
	
	@FetchRequest(
		entity: CertificatePair.entity(),
		sortDescriptors: [NSSortDescriptor(keyPath: \CertificatePair.date, ascending: false)],
		animation: .snappy
	) private var certificates: FetchedResults<CertificatePair>
	
	var body: some View {
		FRNavigationView("Debug") {
			List {
				Section("This is meant to be seen on debug builds") {
					Text("Debug")
						.foregroundStyle(.secondary)
				}
				
				if certificates.indices.contains(selectedCert) {
					let selectedCertificate = certificates[selectedCert]
					CertificatesCellView(cert: selectedCertificate, selectedInfoCert: .constant(.none))
				} else {
					Text("No valid certificate selected.")
				}
				
				NavigationLink("Preview with Temporary Changes", destination: TemporarySettingsView())
			}
		}
	}
}

struct TemporarySettingsView: View {
	@StateObject private var optionsManager = OptionsManager.shared
	@State private var temporaryOptions: Options = OptionsManager.shared.options
	
	var body: some View {
		SigningOptionsView(
			options: $temporaryOptions,
			temporaryOptions: optionsManager.options
		)
		.navigationTitle("Preview Settings")
		.onReceive(optionsManager.objectWillChange) { _ in
			temporaryOptions = optionsManager.options
		}
	}
}

#endif
