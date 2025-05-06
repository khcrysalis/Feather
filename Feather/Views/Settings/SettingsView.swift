//
//  SettingsView.swift
//  Feather
//
//  Created by samara on 10.04.2025.
//

import SwiftUI
import NimbleViews
#if SERVER
import NimbleJSON
#endif
import Zip

// MARK: - View
struct SettingsView: View {
	#if SERVER
	typealias ServerPackDataHandler = Result<ServerPackModel, Error>
	private let _dataService = NBFetchService()
	private let _fServerPack = "https://backloop.dev/pack.json"
	#endif
	
	@AppStorage("Feather.compressionLevel") private var _compressionLevel: Int = ZipCompression.DefaultCompression.rawValue
	@AppStorage("Feather.useShareSheetForArchiving") private var _useShareSheet: Bool = false
	
	#if SERVER
	@AppStorage("Feather.ipFix") private var _ipFix: Bool = false
	@AppStorage("Feather.serverMethod") private var _serverMethod: Int = 0
	private let _serverMethods = ["Fully Local", "Semi Local"]
	#endif
	
	private let _kDonations = "https://github.com/sponsors/khcrysalis"
	private let _fGithub = "https://github.com/khcrysalis/Feather"
	
	// MARK: Body
    var body: some View {
		NBNavigationView("Settings") {
            List {
				#if !NIGHTLY
				SettingsDonationCellView(site: _kDonations)
				#endif
				
				_feedback()
				
				NBSection("Signing") {
					NavigationLink("Certificates", destination: CertificatesView())
					NavigationLink("Global Configuration", destination: ConfigurationView())
				}

				NBSection("Archive") {
					Picker("Compression Level", selection: $_compressionLevel) {
						ForEach(ZipCompression.allCases, id: \.rawValue) { level in
							Text(level.label).tag(level)
						}
					}
					Toggle("Show Sheet when Exporting", isOn: $_useShareSheet)
				} footer: {
					Text("Toggling show sheet will present a share sheet after exporting to your files.")
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
					Button("Update SSL Certificates") {
						FR.downloadSSLCertificates(from: _fServerPack) { success in
							if !success {
								DispatchQueue.main.async {
									UIAlertController.showAlertWithOk(
										title: "SSL Certificates",
										message: "Failed to download, check your internet connection and try again."
									)
								}
							}
						}

					}
				}
				#elseif IDEVICE
				NBSection("Pairing") {
					NavigationLink("Tunnel & Pairing", destination: TunnelView())
				}
				#endif
				
				_directories()
            }
			#if SERVER
			.onChange(of: _serverMethod) { _ in
				UIAlertController.showAlertWithRestart(
					title: "Restart Required",
					message: "These changes require a restart of the app"
				)
			}
			#endif
        }
		
    }
}

// MARK: - View extension
extension SettingsView {
	@ViewBuilder
	private func _feedback() -> some View {
		Section {
			NavigationLink("About", destination: AboutView())
			Button("Submit Feedback", systemImage: "safari") {
				UIApplication.open("\(_fGithub)/issues")
			}
			Button("GitHub Repository", systemImage: "safari") {
				UIApplication.open(_fGithub)
			}
		}
	}
	
	@ViewBuilder
	private func _directories() -> some View {
		Section {
			Button("Open Documents", systemImage: "folder") {
				UIApplication.open(URL.documentsDirectory.toSharedDocumentsURL()!)
			}
			Button("Open Archives", systemImage: "folder") {
				UIApplication.open(FileManager.default.archives.toSharedDocumentsURL()!)
			}
			Button("Open Certificates", systemImage: "folder") {
				UIApplication.open(FileManager.default.certificates.toSharedDocumentsURL()!)
			}
		} footer: {
			Text("All of Feathers files are contained in the documents directory, here are some quick links to these.")
		}
	}
}
