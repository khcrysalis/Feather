//
//  CertificateCellView.swift
//  Feather
//
//  Created by samara on 16.04.2025.
//

import SwiftUI

// MARK: - View
struct CertificatesCellView: View {
	@State var data: Certificate?
	
	var cert: CertificatePair
	var shouldDisplayInfo: Bool = true
	@Binding var isSelectedInfoPresenting: CertificatePair?
	
	// MARK: Body
	var body: some View {
		VStack(spacing: 6) {
			if let data = data {
				VStack(alignment: .leading) {
					Text(cert.nickname ?? data.Name)
						.font(.headline)
						.bold()
					Text(data.AppIDName)
						.font(.caption)
						.foregroundStyle(.secondary)
				}
				.lineLimit(0)
				.frame(maxWidth: .infinity, alignment: .leading)
				
				_certInfoPill(data: data)
			}
		}
		.frame(height: 80)
		.contentTransition(.opacity)
		.frame(maxWidth: .infinity, alignment: .leading)
		.onAppear {
			withAnimation {
				data = Storage.shared.getProvisionFileDecoded(for: cert)
			}
		}
	}
}

// MARK: - Extension: View
extension CertificatesCellView {
	@ViewBuilder
	private func _certInfoPill(data: Certificate) -> some View {
		let pillItems = _buildPills(from: data)
		HStack(spacing: 6) {
			ForEach(pillItems.indices, id: \.hashValue) { index in
				let pill = pillItems[index]
				FRPillView(
					title: pill.title,
					icon: pill.icon,
					color: pill.color,
					index: index,
					count: pillItems.count
				)
			}
		}
	}
	
	private func _buildPills(from cert: Certificate) -> [FRPillItem] {
		var pills: [FRPillItem] = []
		
		if cert.PPQCheck == true {
			pills.append(FRPillItem(title: "PPQCheck", icon: "checkmark.shield", color: .red))
		}
		
		let expirationInfo = cert.ExpirationDate.expirationInfo()
		pills.append(FRPillItem(
			title: expirationInfo.formatted,
			icon: expirationInfo.icon,
			color: expirationInfo.color
		))
		
		return pills
	}
}
