//
//  ContentView.swift
//  Feather
//
//  Created by samara on 10.04.2025.
//

import SwiftUI
import CoreData

// MARK: - View
struct LibraryView: View {
	@State private var isImportingFiles = false
	@State private var searchText = ""
	@State private var selectedInfoApp: AnyApp?
	@State private var selectedSigningApp: AnyApp?
		
	@Namespace private var namespace
	
	// MARK: Fetch
	@FetchRequest(
		entity: Signed.entity(),
		sortDescriptors: [NSSortDescriptor(keyPath: \Signed.date, ascending: false)],
		animation: .snappy
	) private var signedApps: FetchedResults<Signed>
	
	@FetchRequest(
		entity: Imported.entity(),
		sortDescriptors: [NSSortDescriptor(keyPath: \Imported.date, ascending: false)],
		animation: .snappy
	) private var importedApps: FetchedResults<Imported>
	
	// MARK: Body
    var body: some View {
		FRNavigationView("Library") {
			List {
				FRSection("Signed") {
					ForEach(signedApps, id: \.uuid) { app in
						LibraryCellView(app: app, selectedInfoApp: $selectedInfoApp, selectedSigningApp: $selectedSigningApp)
							.compatMatchedTransitionSource(id: app.uuid ?? "", ns: namespace)
					}
				}
				FRSection("Imported") {
					ForEach(importedApps, id: \.uuid) { app in
						LibraryCellView(app: app, selectedInfoApp: $selectedInfoApp, selectedSigningApp: $selectedSigningApp)
							.compatMatchedTransitionSource(id: app.uuid ?? "", ns: namespace)
					}
				}
			}
			.listStyle(.plain)
			.searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
			.toolbar {
				FRToolbarMenu(
					"Import",
					systemImage: "plus",
					style: .icon,
					placement: .topBarTrailing
				) {
					Button("Import from Files") {
						isImportingFiles = true
					}
				}
			}
			.sheet(item: $selectedInfoApp) { app in
				LibraryInfoView(app: app.base)
			}
			.fullScreenCover(item: $selectedSigningApp) { app in
				SigningView(app: app.base)
					.compatNavigationTransition(id: app.base.uuid ?? "", ns: namespace)
			}
			.fileImporter(
				isPresented: $isImportingFiles,
				allowedContentTypes: [.ipa, .tipa]
			) { result in
				if case .success(let file) = result {
					if file.startAccessingSecurityScopedResource() {
						FR.handlePackageFile(file) { _ in }
					}
				}
			}
        }
    }
}
