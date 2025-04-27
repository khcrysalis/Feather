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
			VStack(alignment: .leading, spacing: 2) {
				Text(cert.nickname ?? data?.Name ?? "Unknown")
					.font(.headline.weight(.bold))
				Text(data?.AppIDName ?? "Unknown")
					.font(.caption)
					.foregroundStyle(.secondary)
			}
			.frame(maxWidth: .infinity, alignment: .leading)
			
			_certInfoPill(data: cert)
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
	private func _certInfoPill(data: CertificatePair) -> some View {
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
	
	private func _buildPills(from cert: CertificatePair) -> [FRPillItem] {
		var pills: [FRPillItem] = []
		
		if cert.ppQCheck == true {
			pills.append(FRPillItem(title: "PPQCheck", icon: "checkmark.shield", color: .red))
		}
		
		if let info = cert.expiration?.expirationInfo() {
			pills.append(FRPillItem(
				title: info.formatted,
				icon: info.icon,
				color: info.color
			))
		}
		
		return pills
	}
}
