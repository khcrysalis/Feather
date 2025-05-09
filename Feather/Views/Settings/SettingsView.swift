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
		NBNavigationView(.localized("Settings")) {
			Form {
				#if !NIGHTLY
				SettingsDonationCellView(site: _donationsUrl)
				#endif
				
				_feedback()
				
				Section {
					NavigationLink(String.localized("Appearance"), destination: AppearanceView())
				}
				
				NBSection(.localized("Features")) {
					NavigationLink(String.localized("Certificates"), destination: CertificatesView())
					NavigationLink(String.localized("Signing Options"), destination: ConfigurationView())
					NavigationLink(String.localized("Archive & Compression"), destination: ArchiveView())
					#if SERVER
					NavigationLink(String.localized("Server & SSL"), destination: ServerView())
					#elseif IDEVICE
					NavigationLink(String.localized("Tunnel & Pairing"), destination: TunnelView())
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
			NavigationLink(String.localized("About"), destination: AboutView())
			Button(String.localized("Submit Feedback"), systemImage: "safari") {
				UIApplication.open("\(_githubUrl)/issues")
			}
			Button(String.localized("GitHub Repository"), systemImage: "safari") {
				UIApplication.open(_githubUrl)
			}
		}
	}
	
	@ViewBuilder
	private func _directories() -> some View {
		NBSection(.localized("Misc")) {
			Button(String.localized("Open Documents"), systemImage: "folder") {
				UIApplication.open(URL.documentsDirectory.toSharedDocumentsURL()!)
			}
			Button(String.localized("Open Archives"), systemImage: "folder") {
				UIApplication.open(FileManager.default.archives.toSharedDocumentsURL()!)
			}
			Button(String.localized("Open Certificates"), systemImage: "folder") {
				UIApplication.open(FileManager.default.certificates.toSharedDocumentsURL()!)
			}
		} footer: {
			Text(String.localized("All of Feathers files are contained in the documents directory, here are some quick links to these."))
		}
	}
}
