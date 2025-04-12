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
	
	@FetchRequest(entity: Imported.entity(),
		sortDescriptors: [NSSortDescriptor(keyPath: \Imported.date, ascending: false)],
		animation: .snappy
	) private var importedApps: FetchedResults<Imported>
	
	@State private var isImportingFiles = false
	@State private var searchText = ""
	
	var filteredApps: [Imported] {
		if searchText.isEmpty {
			return Array(importedApps)
		} else {
			return importedApps.filter {
				($0.name ?? "").localizedCaseInsensitiveContains(searchText) ||
				($0.identifier ?? "").localizedCaseInsensitiveContains(searchText)
			}
		}
	}

    var body: some View {
		NavigationViewWrapper("Library") {
			List {
				SectionProminentHeaderWrapper("Imported") {
					ForEach(filteredApps, id: \.uuid) { app in
						LibraryAppIconView(app)
					}
				}
			}
			.searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
			.listStyle(.plain)
			.toolbar {
				ToolbarMenuWrapper(
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
	
	#warning("importing 2 files at once may be a bad idea. will fix later?")
	private func _import(file ipa: URL) {
		Task.detached {
			try? await Task.sleep(nanoseconds: 1_000)
			let handler = ImportedFileHandler(file: ipa)
			
			do {
				try await handler.copy()
				ipa.stopAccessingSecurityScopedResource()
				try await handler.extract()
				try await handler.addToDatabase()
			} catch {
				print(error)
			}
		}
	}
}

