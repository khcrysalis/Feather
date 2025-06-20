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
	@State private var _currentIcon: String? = UIApplication.shared.alternateIconName
	
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
					if UIDevice.current.doesHaveAppIdCapabilities {
						NavigationLink(.localized("App Icon"), destination: AppIconView(currentIcon: $_currentIcon))
					}
				}
				
				NBSection(.localized("Features")) {
					NavigationLink(.localized("Certificates"), destination: CertificatesView())
					NavigationLink(.localized("Signing Options"), destination: ConfigurationView())
					NavigationLink(.localized("Archive & Compression"), destination: ArchiveView())
					NavigationLink(.localized("Installation"), destination: InstallationView())
				}
				
				_directories()
				
				Section {
					NavigationLink(.localized("Reset"), destination: ResetView())
				}
            }
        }
    }
}

// MARK: - View extension
extension SettingsView {
	@ViewBuilder
	private func _feedback() -> some View {
		Section {
			NavigationLink(destination: AboutView()) {
				Label {
					Text(verbatim: .localized("About %@", arguments: Bundle.main.name))
				} icon: {
					Image(uiImage: AppIconView.altImage(_currentIcon))
						.appIconStyle(size: 23)
				}
			}
			
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
