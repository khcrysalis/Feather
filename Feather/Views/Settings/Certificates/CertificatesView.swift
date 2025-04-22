//
//  CertificatesView.swift
//  Feather
//
//  Created by samara on 15.04.2025.
//

import SwiftUI

// MARK: - View
struct CertificatesView: View {
	@AppStorage("feather.selectedCert") private var storedSelectedCert: Int = 0
	
	@State private var isAddingCert = false
	@State private var selectedInfoCert: CertificatePair?
	
	let columns: [GridItem] = [
		GridItem(.adaptive(minimum: 300))
	]


	// MARK: Fetch
	@FetchRequest(
		entity: CertificatePair.entity(),
		sortDescriptors: [NSSortDescriptor(keyPath: \CertificatePair.date, ascending: false)],
		animation: .snappy
	) private var certificates: FetchedResults<CertificatePair>
	
	//
	private var bindingSelectedCert: Binding<Int>?
	private var selectedCertBinding: Binding<Int> {
		bindingSelectedCert ?? $storedSelectedCert
	}
	
	init(selectedCert: Binding<Int>? = nil) {
		self.bindingSelectedCert = selectedCert
	}
	
	// MARK: Body
	var body: some View {
		ScrollView {
			LazyVGrid(columns: columns, spacing: 16) {
				ForEach(Array(certificates.enumerated()), id: \.element.uuid) { index, cert in
					_cellButton(for: cert, at: index)
				}
			}
			.padding()
		}
		.navigationTitle("Certificates")
		.navigationBarTitleDisplayMode(.inline)
		.toolbar {
			if bindingSelectedCert == nil {
				FRToolbarButton(
					"Add",
					systemImage: "plus",
					style: .icon,
					placement: .topBarTrailing
				) {
					isAddingCert = true
				}
			}
		}
		.sheet(item: $selectedInfoCert) { cert in
			CertificatesInfoView(cert: cert)
		}
		.sheet(isPresented: $isAddingCert) {
			CertificatesAddView()
				.presentationDetents([.medium])
		}
	}
}

extension CertificatesView {
	@ViewBuilder
	private func _cellButton(for cert: CertificatePair, at index: Int) -> some View {
		Button {
			selectedCertBinding.wrappedValue = index
		} label: {
			CertificatesCellView(
				cert: cert,
				selectedInfoCert: $selectedInfoCert
			)
			.padding()
			.frame(maxWidth: .infinity)
			.background(
				RoundedRectangle(cornerRadius: 17)
					.fill(Color(uiColor: .quaternarySystemFill))
			)
			.overlay(
				RoundedRectangle(cornerRadius: 17)
					.strokeBorder(
						selectedCertBinding.wrappedValue == index ? Color.accentColor : Color.clear,
						lineWidth: 2
					)
			)
			.contextMenu {
				_contextActions(for: cert)
				Divider()
				_actions(for: cert)
			}
			.animation(.smooth, value: selectedCertBinding.wrappedValue)
		}
		.buttonStyle(.plain)
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
			selectedInfoCert = cert
		} label: {
			Label("Get Info", systemImage: "info.circle")
		}
	}
}
