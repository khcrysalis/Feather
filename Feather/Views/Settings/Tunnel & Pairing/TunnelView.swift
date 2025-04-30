//
//  SettingsTunnelView.swift
//  Feather (idevice)
//
//  Created by samara on 29.04.2025.
//

import SwiftUI
import NimbleViews

// MARK: - View
struct TunnelView: View {
	@State private var _isImportingPairingPresenting = false
	
	// MARK: Body
    var body: some View {
		Form {
			Section {
				_tunnelInfo()
				TunnelHeaderView()
			} footer: {
				if FileManager.default.fileExists(atPath: HeartbeatManager.pairingFile()) {
					Text("Seems like you've gotten your hands on your pairing file! If you encounter ever `InvalidHostID -9` error please make a new pairing file and import it.")
				} else {
					Text("No pearing file found, please import it.")
				}
			}
			
			Section {
				Button("Import Pairing File", systemImage: "square.and.arrow.down") {
					_isImportingPairingPresenting = true
				}
				Button("Restart Heartbeat", systemImage: "arrow.counterclockwise") {
					HeartbeatManager.shared.start(true)
				}
			}
			
			NBSection("Help") {
				Button("Pairing File Guide", systemImage: "questionmark.circle") {
					UIApplication.open("https://github.com/StephenDev0/StikDebug-Guide/blob/main/pairing_file.md")
				}
			}
		}
		.navigationTitle("Tunnel & Pairing")
		.navigationBarTitleDisplayMode(.inline)
		.sheet(isPresented: $_isImportingPairingPresenting) {
			FileImporterRepresentableView(
				allowedContentTypes:  [.xmlPropertyList, .plist, .mobiledevicepairing],
				onDocumentsPicked: { urls in
					guard let selectedFileURL = urls.first else { return }
					FR.movePairing(selectedFileURL)
				}
			)
		}
    }
	
	@ViewBuilder
	private func _tunnelInfo() -> some View {
		HStack {
			VStack(alignment: .leading, spacing: 6) {
				Text("Heartbeat")
					.font(.headline)
					.bold()
				Text("The heartbeat is activated in the background, it will restart when the app is re-opened or prompted. If the status below is pulsing, that means its healthy.")
					.font(.subheadline)
					.foregroundStyle(.secondary)
			}
			.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
		}
	}
}
