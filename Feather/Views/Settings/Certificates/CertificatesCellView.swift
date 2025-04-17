//
//  CertificateCellView.swift
//  Feather
//
//  Created by samara on 16.04.2025.
//

import SwiftUI

struct CertificatesCellView: View {
	var cert: CertificatePair
	var isSelected: Bool
	@State var data: Certificate?
	
	var body: some View {
		VStack(spacing: 6) {
			if let cert = data {
				VStack(alignment: .leading) {
					Text(cert.Name)
						.font(.headline)
						.bold()
					Text(cert.AppIDName)
						.font(.caption)
						.foregroundStyle(.secondary)
				}
				.lineLimit(0)
				.frame(maxWidth: .infinity, alignment: .leading)
				
				_certInfoPill(data: cert)
			}
		}
		.overlay(
			isSelected ? Image(systemName: "checkmark.circle.fill")
				.foregroundStyle(.accent)
			: nil,
			alignment: .topTrailing
		)
		.animation(.easeInOut, value: isSelected)
		.frame(height: 80)
		.contentTransition(.opacity)
		.frame(maxWidth: .infinity, alignment: .leading)
		.swipeActions {
			_actions(for: cert)
		}
		.contextMenu {
			_contextActions(for: cert)
			Divider()
			_actions(for: cert)
		}
		.onAppear {
			data = Storage.shared.getProvisionFileDecoded(for: cert)
		}
	}
	
	@ViewBuilder
	private func _actions(for cert: CertificatePair) -> some View {
		Button(role: .destructive) {
			Storage.shared.deleteCertificate(for: cert)
		} label: {
			Label("Delete", systemImage: "trash")
		}
	}
	
	@ViewBuilder
	private func _contextActions(for cert: CertificatePair) -> some View {
		Button {
		} label: {
			Label("Get Info", systemImage: "info.circle")
		}
	}
	
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
