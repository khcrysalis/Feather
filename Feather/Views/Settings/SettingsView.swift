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
				
                NBSection(.localized("General")) {
                    NavigationLink(destination: AppearanceView()) {
                        FRTintedIconLabelView("Appearance", systemName: "eye.fill", tintColor: .blue)
                    }
				}
				
				NBSection(.localized("Features")) {
                    NavigationLink(destination: CertificatesView()) {
                        FRTintedIconLabelView("Certificates", systemName: "checkmark.seal.text.page.fill", tintColor: .green)
                    }
                    
                    NavigationLink(destination: ConfigurationView()) {
                        FRTintedIconLabelView("Signing Options", systemName: "signature", tintColor: .red)
                    }
                    
                    NavigationLink(destination: ArchiveView()) {
                        FRTintedIconLabelView("Archive & Compression", systemName: "archivebox.fill", tintColor: .orange)
                    }
                    
					#if SERVER
                    NavigationLink(destination: ServerView()) {
                        FRTintedIconLabelView("Server & SSL", systemName: "server.rack", tintColor: .blue)
                    }
					#elseif IDEVICE
                    NavigationLink(destination: TunnelView()) {
                        FRTintedIconLabelView("Tunnel & Pairing", systemName: "personalhotspot", tintColor: .blue)
                    }
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
        NBSection(Bundle.main.name) {
            NavigationLink(destination: AboutView()) {
                FRTintedIconLabelView("About", name: "Glyph", tintColor: .accentColor)
            }
            
            Button {
                UIApplication.open("\(_githubUrl)/issues")
            } label: {
                FRTintedIconLabelView("Submit Feedback", systemName: "exclamationmark.bubble.fill", tintColor: .purple, showLinkHint: true)
            }
            .foregroundStyle(.primary)
            
            Button {
                UIApplication.open(_githubUrl)
            } label: {
                FRTintedIconLabelView("GitHub Repository", name: "Github_Logo", tintColor: .black, showLinkHint: true)
            }
            .foregroundStyle(.primary)
		}
	}
	
	@ViewBuilder
	private func _directories() -> some View {
		NBSection(.localized("Misc")) {
            
            Button {
                UIApplication.open(URL.documentsDirectory.toSharedDocumentsURL()!)
            } label: {
                FRTintedIconLabelView("Open Documents", systemName: "folder.fill", tintColor: .blue, showLinkHint: true)
            }
            .foregroundStyle(.primary)
            
            Button {
                UIApplication.open(FileManager.default.archives.toSharedDocumentsURL()!)
            } label: {
                FRTintedIconLabelView("Open Archives", systemName: "folder.fill", tintColor: .blue, showLinkHint: true)
            }
            .foregroundStyle(.primary)
            
            Button {
                UIApplication.open(FileManager.default.certificates.toSharedDocumentsURL()!)
            } label: {
                FRTintedIconLabelView("Open Certificates", systemName: "folder.fill", tintColor: .blue, showLinkHint: true)
            }
            .foregroundStyle(.primary)
            
		} footer: {
			Text(.localized("All of Feathers files are contained in the documents directory, here are some quick links to these."))
		}
	}
}
