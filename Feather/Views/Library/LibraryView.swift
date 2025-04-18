//
//  ContentView.swift
//  Feather
//
//  Created by samara on 10.04.2025.
//

import SwiftUI
import CoreData

struct LibraryView: View {
    @Environment(\.managedObjectContext) private var managedObjectContext
	@State private var isImportingFiles = false
	@State private var searchText = ""
	@State private var selectedInfoApp: AnyApp?
	@State private var selectedSigningApp: AnyApp?

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

    var body: some View {
		FRNavigationView("Library") {
			List {
				FRSection("Signed") {
					ForEach(signedApps, id: \.uuid) { app in
						Button(action: {
							selectedSigningApp = AnyApp(base: app)
						}) {
							LibraryCellView(app: app, selectedApp: $selectedInfoApp)
						}
					}
				}
				FRSection("Imported") {
					ForEach(importedApps, id: \.uuid) { app in
						Button(action: {
							selectedSigningApp = AnyApp(base: app)
						}) {
							LibraryCellView(app: app, selectedApp: $selectedInfoApp)
						}
					}
				}
			}
			.sheet(item: $selectedInfoApp) { app in
				LibraryInfoView(app: app.base)
			}
			.fullScreenCover(item: $selectedSigningApp) { app in
				SigningView(app: app.base)
			}
			.searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
			.listStyle(.plain)
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
			.fileImporter(
				isPresented: $isImportingFiles,
				allowedContentTypes: [.ipa, .tipa]
			) { result in
				switch result {
				case .success(let file):
					if file.startAccessingSecurityScopedResource() {
						self._import(file: file)
					}
				case .failure(let error):
					print(error.localizedDescription)
				}
			}
        }
    }
	
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
				print(error)
			}
		}
	}
}

