//
//  CertificatesInfoView.swift
//  Feather
//
//  Created by samara on 20.04.2025.
//

import SwiftUI

struct CertificatesInfoView: View {
	@Environment(\.dismiss) var dismiss
	@State var data: Certificate?
	
	var cert: CertificatePair
	
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
				if let cert = data {
					FRSection("Info") {
						_info("Name", description: cert.Name)
						_info("AppID Name", description: cert.AppIDName)
						_info("Team Name", description: cert.TeamName)
					}
					
					Section {
						_info("Expires", description: cert.ExpirationDate.expirationInfo().formatted)
							.foregroundStyle(cert.ExpirationDate.expirationInfo().color)
						if let ppq = cert.PPQCheck {
							_info("PPQCheck", description: ppq.description)
						}
					}
					
					Section {
						_disclosure("Platform", keys: cert.Platform)
						
						if let all = cert.ProvisionsAllDevices {
							_info("Provision All Devices", description: all.description)
						}
						
						if let devices = cert.ProvisionedDevices {
							_disclosure("Provisioned Devices", keys: devices)
						}
						
						_disclosure("Team Identifiers", keys: cert.TeamIdentifier)
						
						if let prefix = cert.ApplicationIdentifierPrefix{
							_disclosure("Identifier Prefix", keys: prefix)
						}
					}
				}
			}
			.toolbar {
				FRToolbarButton(
					"Close",
					systemImage: "xmark",
					placement: .topBarTrailing
				) {
					dismiss()
				}
			}
		}
		.onAppear {
			data = Storage.shared.getProvisionFileDecoded(for: cert)
		}
    }
	
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

