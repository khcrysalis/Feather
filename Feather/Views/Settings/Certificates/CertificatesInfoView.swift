//
//  CertificatesInfoView.swift
//  Feather
//
//  Created by samara on 20.04.2025.
//

import SwiftUI
import NimbleViews

// MARK: - View
struct CertificatesInfoView: View {
	@Environment(\.dismiss) var dismiss
	@State var data: Certificate?
	
	var cert: CertificatePair
	
	// MARK: Body
    var body: some View {
		FRNavigationView(cert.nickname ?? "", displayMode: .inline) {
			Form {
				Section {} header: {
					Image("Cert")
						.resizable()
						.scaledToFit()
						.frame(width: 107, height: 107)
						.frame(maxWidth: .infinity, alignment: .center)
				}
				if let data {
					FRSection("Info") {
						_info("Name", description: data.Name)
						_info("AppID Name", description: data.AppIDName)
						_info("Team Name", description: data.TeamName)
					}
					
					Section {
						_info("Expires", description: data.ExpirationDate.expirationInfo().formatted)
							.foregroundStyle(data.ExpirationDate.expirationInfo().color)
						if let ppq = data.PPQCheck {
							_info("PPQCheck", description: ppq.description)
						}
					}
					
					_entitlements(data: data)
					
					FRSection("Misc") {
						_disclosure("Platform", keys: data.Platform)
						
						if let all = data.ProvisionsAllDevices {
							_info("Provision All Devices", description: all.description)
						}
						
						if let devices = data.ProvisionedDevices {
							_disclosure("Provisioned Devices", keys: devices)
						}
						
						_disclosure("Team Identifiers", keys: data.TeamIdentifier)
						
						if let prefix = data.ApplicationIdentifierPrefix{
							_disclosure("Identifier Prefix", keys: prefix)
						}
					}
				}
			}
			.toolbar {
				NBToolbarButton(role: .close)
			}
		}
		.onAppear {
			data = Storage.shared.getProvisionFileDecoded(for: cert)
		}
    }
	
	@ViewBuilder
	private func _entitlements(data: Certificate) -> some View {
		if let entitlements = data.Entitlements {
			NBSection("Entitlements") {
				NavigationLink("View Entitlements") {
					CertificatesInfoEntitlementView(entitlements: entitlements)
				}
			}
		}
	}
}

// MARK: - Extension: View
extension CertificatesInfoView {
	@ViewBuilder
	private func _info(_ title: String, description: String) -> some View {
		LabeledContent(title) {
			Text(description)
		}
	}
	
	@ViewBuilder
	private func _disclosure(_ title: String, keys: [String]) -> some View {
		DisclosureGroup(title) {
			ForEach(keys, id: \.self) { key in
				Text(key)
					.foregroundStyle(.secondary)
			}
		}
	}
}
