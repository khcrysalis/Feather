//
//  CertificatesInfoEntitlementView.swift
//  Feather
//
//  Created by samara on 27.04.2025.
//

import SwiftUI
import NimbleViews

// MARK: - View
struct CertificatesInfoEntitlementView: View {
	let entitlements: [String: AnyCodable]
	
	// MARK: Body
	var body: some View {
		NBList(.localized("Entitlements")) {
			ForEach(entitlements.keys.sorted(), id: \.self) { key in
				if let value = entitlements[key]?.value {
					CertificatesInfoEntitlementCellView(key: key, value: value)
				}
			}
		}
		.listStyle(.grouped)
	}
}
