//
//  CertificatesView.swift
//  Feather
//
//  Created by samara on 15.04.2025.
//

import SwiftUI

struct CertificatesView: View {
	@Environment(\.managedObjectContext) private var managedObjectContext
	@AppStorage("feather.selectedCert") var selectedCert: Int = 0
	@State private var isAddingCert = false
	
	@FetchRequest(
		entity: CertificatePair.entity(),
		sortDescriptors: [NSSortDescriptor(keyPath: \CertificatePair.date, ascending: false)],
		animation: .snappy
	) private var certificates: FetchedResults<CertificatePair>
	
    var body: some View {
		List {
			ForEach(certificates, id: \.uuid) { cert in
				Text(cert.uuid!)
			}
		}
		.navigationTitle("Certificates")
		.navigationBarTitleDisplayMode(.inline)
		.toolbar {
			FRToolbarButton(
				"Add",
				systemImage: "plus",
				style: .icon,
				placement: .topBarTrailing
			) {
				print("add")
				isAddingCert = true
			}
		}
		.sheet(isPresented: $isAddingCert) {
			CertificatesAddView()
				.presentationDetents([.medium])
		}
    }
}
