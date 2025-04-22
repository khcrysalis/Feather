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
					}
				}
				FRSection("Imported") {
					ForEach(importedApps, id: \.uuid) { app in
						LibraryCellView(app: app, selectedInfoApp: $selectedInfoApp, selectedSigningApp: $selectedSigningApp)
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
			}
			.fileImporter(
				isPresented: $isImportingFiles,
				allowedContentTypes: [.ipa, .tipa]
			) { result in
				if case .success(let file) = result {
					if file.startAccessingSecurityScopedResource() {
						self._import(file: file)
					}
				}
			}
        }
    }
}

// MARK: - Extension: View
extension LibraryView {
	private func _import(file ipa: URL) {
		Task.detached {
			defer {
				ipa.stopAccessingSecurityScopedResource()
			}
			
			let handler = AppFileHandler(file: ipa)
			
			do {
				try await handler.copy()
				try await handler.extract()
				try await handler.move()
				try await handler.addToDatabase()
			} catch {
				try await handler.clean()
				print(error)
			}
		}
	}
}
