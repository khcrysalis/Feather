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
				#if !NIGHTLY && !DEBUG
				SettingsDonationCellView(site: _donationsUrl)
				#endif
				
				_feedback()
				
				Section {
					NavigationLink(.localized("Appearance"), destination: AppearanceView())
				}
				
				NBSection(.localized("Features")) {
					NavigationLink(.localized("Certificates"), destination: CertificatesView())
					NavigationLink(.localized("Signing Options"), destination: ConfigurationView())
					NavigationLink(.localized("Archive & Compression"), destination: ArchiveView())
					NavigationLink(.localized("Installation"), destination: InstallationView())
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
			NavigationLink(.localized("About"), destination: AboutView())
			Button(.localized("Submit Feedback"), systemImage: "safari") {
				UIApplication.open("\(_githubUrl)/issues")
			}
			Button(.localized("GitHub Repository"), systemImage: "safari") {
				UIApplication.open(_githubUrl)
			}
		}
	}
	
	@ViewBuilder
	private func _directories() -> some View {
		NBSection(.localized("Misc")) {
			Button(.localized("Open Documents"), systemImage: "folder") {
				UIApplication.open(URL.documentsDirectory.toSharedDocumentsURL()!)
			}
			Button(.localized("Open Archives"), systemImage: "folder") {
				UIApplication.open(FileManager.default.archives.toSharedDocumentsURL()!)
			}
			Button(.localized("Open Certificates"), systemImage: "folder") {
				UIApplication.open(FileManager.default.certificates.toSharedDocumentsURL()!)
			}
		} footer: {
			Text(.localized("All of Feathers files are contained in the documents directory, here are some quick links to these."))
		}
	}
}
