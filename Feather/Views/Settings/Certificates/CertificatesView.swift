//
//  CertificatesView.swift
//  Feather
//
//  Created by samara on 15.04.2025.
//

import SwiftUI

struct CertificatesView: View {
	@Environment(\.managedObjectContext) private var managedObjectContext
	@AppStorage("feather.selectedCert") private var storedSelectedCert: Int = 0
	@State private var isAddingCert = false
	@State private var selectedInfoCert: CertificatePair?
	//
	//
	//
	@FetchRequest(
		entity: CertificatePair.entity(),
		sortDescriptors: [NSSortDescriptor(keyPath: \CertificatePair.date, ascending: false)],
		animation: .snappy
	) private var certificates: FetchedResults<CertificatePair>
	
	//
	//
	//
	private var bindingSelectedCert: Binding<Int>?
	private var selectedCertBinding: Binding<Int> {
		bindingSelectedCert ?? $storedSelectedCert
	}
	
	init(selectedCert: Binding<Int>? = nil) {
		self.bindingSelectedCert = selectedCert
	}
	
	var body: some View {
		List(Array(certificates.enumerated()), id: \.element.uuid) { index, cert in
			Button {
				selectedCertBinding.wrappedValue = index
			} label: {
				CertificatesCellView(cert: cert, isSelected: selectedCertBinding.wrappedValue == index, selectedInfoCert: $selectedInfoCert)
			}
			.buttonStyle(.plain)
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
