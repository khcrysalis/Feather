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
	@State private var isPresenting = false
	
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
					CertificatesCellView(cert: selectedCertificate, isSelected: false)
				} else {
					Text("No valid certificate selected.")
				}
				
				Button("Test bottom sheet") {
					isPresenting = true
				}
				
				NavigationLink("Preview with Temporary Changes", destination: TemporarySettingsView())
			}
		}
		.sheet(isPresented: $isPresenting) {
			FRBottomSelectionView {
				FRSheetButton("Sign") {
					print("a")
				}
				
				FRSheetButton("Install", role: .secondary) {
					print("a")
				}
			}
			.compatPresentationRadius(21)
			.presentationDragIndicator(.visible)
			.presentationDetents([.custom(FRBottomDetent.self)])
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
