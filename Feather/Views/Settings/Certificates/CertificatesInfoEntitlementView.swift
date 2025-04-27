//
//  CertificatesInfoEntitlementView.swift
//  Feather
//
//  Created by samara on 27.04.2025.
//

import SwiftUI

struct CertificatesInfoEntitlementView: View {
	let entitlements: [String: AnyCodable]
	
	var body: some View {
		List {
			ForEach(entitlements.keys.sorted(), id: \.self) { key in
				if let value = entitlements[key]?.value {
					CertificatesInfoEntitlementCellView(key: key, value: value)
				}
			}
		}
		.navigationTitle("Entitlements")
		.listStyle(.grouped)
	}
}
