//
//  SettingsView.swift
//  Feather
//
//  Created by samara on 10.04.2025.
//

import SwiftUI
import NimbleViews

// MARK: - View
struct SettingsView: View {
	private let _donationsUrl = "https://github.com/sponsors/khcrysalis"
	private let _githubUrl = "https://github.com/khcrysalis/Feather"
	
	// MARK: Body
    var body: some View {
		NBNavigationView("Settings") {
			Form {
				#if !NIGHTLY
				SettingsDonationCellView(site: _donationsUrl)
				#endif
				
				_feedback()
				
				Section {
					NavigationLink("Appearance", destination: AppearanceView())
				}
				
				NBSection("Features") {
					NavigationLink("Certificates", destination: CertificatesView())
					NavigationLink("Signing Options", destination: ConfigurationView())
					NavigationLink("Archive & Compression", destination: ArchiveView())
					#if SERVER
					NavigationLink("Server & SSL", destination: ServerView())
					#elseif IDEVICE
					NavigationLink("Tunnel & Pairing", destination: TunnelView())
					#endif
				}
				
				_directories()
            }
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
				UIApplication.open("\(_githubUrl)/issues")
			}
			Button("GitHub Repository", systemImage: "safari") {
				UIApplication.open(_githubUrl)
			}
		}
	}
	
	@ViewBuilder
	private func _directories() -> some View {
		NBSection("Misc") {
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
