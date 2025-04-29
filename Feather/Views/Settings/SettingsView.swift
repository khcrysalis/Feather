//
//  SettingsView.swift
//  Feather
//
//  Created by samara on 10.04.2025.
//

import SwiftUI
import NimbleViews
import Zip

// MARK: - View
struct SettingsView: View {
	@AppStorage("Feather.compressionLevel") private var _compressionLevel: Int = ZipCompression.DefaultCompression.rawValue
	#if SERVER
	@AppStorage("Feather.ipFix") private var _ipFix: Bool = false
	@AppStorage("Feather.serverMethod") private var _serverMethod: Int = 0
	private let _serverMethods = ["Fully Local", "Semi Local"]
	#elseif IDEVICE
	@State private var _isImportingPairingPresenting = false
	@State private var pulseID = UUID()
	#endif
	
	// MARK: Body
    var body: some View {
		NBNavigationView("Settings") {
            List {
				NBSection("Signing") {
					NavigationLink("Certificates", destination: CertificatesView())
					NavigationLink("Configuration", destination: ConfigurationView())
				}

				NBSection("Archive") {
					Picker("Compression Level", selection: $_compressionLevel) {
						ForEach(ZipCompression.allCases, id: \.rawValue) { level in
							Text(level.label).tag(level)
						}
					}
				}
				
				#if SERVER
				NBSection("Server") {
					Picker("Installation Type", selection: $_serverMethod) {
						ForEach(_serverMethods.indices, id: \.self) { index in
							Text(_serverMethods[index]).tag(index)
						}
					}
					Toggle("Only use localhost address", isOn: $_ipFix)
						.disabled(_serverMethod != 1)
				}
				#elseif IDEVICE
				NBSection("Pairing") {
					_heartbeat()
					Button("Restart heartbeat") {
						HeartbeatManager.shared.start(true)
					}
					Button("Import Pairing File") {
						_isImportingPairingPresenting = true
					}
				}
				#endif
				
            }
			#if IDEVICE
			.sheet(isPresented: $_isImportingPairingPresenting) {
				FileImporterRepresentableView(
					allowedContentTypes:  [.xmlPropertyList, .plist, .mobiledevicepairing],
					onDocumentsPicked: { urls in
						guard let selectedFileURL = urls.first else { return }
						FR.movePairing(selectedFileURL)
					}
				)
			}
			#elseif SERVER
			.onChange(of: _serverMethod) { _ in
				UIAlertController.showAlertWithRestart(
					title: "Restart Required",
					message: "These changes require a restart of the app"
				)
			}
			#endif
        }
    }
	
	#if IDEVICE
	@ViewBuilder
	private func _heartbeat() -> some View {
		HStack {
			Text("Status")
			Spacer()
			ZStack {
				Circle()
					.fill(.blue)
					.frame(width: 10, height: 10)
				
				PulseRing(id: pulseID)
			}
		}
		.onReceive(NotificationCenter.default.publisher(for: .heartbeat)) { _ in
			pulseID = UUID()
		}
	}

	#endif
}
#if IDEVICE
struct PulseRing: View {
	let id: UUID
	@State private var animate = false
	
	var body: some View {
		Circle()
			.stroke(.blue, lineWidth: 2)
			.frame(width: 10, height: 10)
			.scaleEffect(animate ? 2.5 : 1)
			.opacity(animate ? 0 : 0.8)
			.onAppear {
				animate = false
				withAnimation(.easeOut(duration: 1)) {
					animate = true
				}
			}
			.id(id)
	}
}
#endif
