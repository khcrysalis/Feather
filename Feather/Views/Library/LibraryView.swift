//
//  ContentView.swift
//  Feather
//
//  Created by samara on 10.04.2025.
//

import SwiftUI
import CoreData
import NimbleViews

// MARK: - View
struct LibraryView: View {
	@State private var _selectedInfoAppPresenting: AnyApp?
	@State private var _selectedSigningAppPresenting: AnyApp?
	@State private var _selectedInstallAppPresenting: AnyApp?
	@State private var _isImportingPresenting = false
	
	@State private var _searchText = ""
	@State private var _selectedScope: Scope = .all
	@State private var _sortOption: SortOption = .date
	@State private var _sortAscending = false
	
	@Namespace private var _namespace
	
	private func filteredAndSortedApps<T>(from apps: FetchedResults<T>) -> [T] where T: NSManagedObject {
		let filtered = apps.filter { app in
			_searchText.isEmpty ||
			((app.value(forKey: "name") as? String)?.localizedCaseInsensitiveContains(_searchText) ?? false)
		}
		
		return filtered.sorted { first, second in
			let comparison: Bool
			switch _sortOption {
			case .date:
				let firstDate = first.value(forKey: "date") as? Date ?? Date()
				let secondDate = second.value(forKey: "date") as? Date ?? Date()
				comparison = firstDate < secondDate
			case .name:
				let firstName = first.value(forKey: "name") as? String ?? ""
				let secondName = second.value(forKey: "name") as? String ?? ""
				comparison = firstName < secondName
			}
			return _sortAscending ? comparison : !comparison
		}
	}
	
	private var _filteredSignedApps: [Signed] {
		filteredAndSortedApps(from: _signedApps)
	}
	
	private var _filteredImportedApps: [Imported] {
		filteredAndSortedApps(from: _importedApps)
	}
	
	// MARK: Fetch
	@FetchRequest(
		entity: Signed.entity(),
		sortDescriptors: [NSSortDescriptor(keyPath: \Signed.date, ascending: false)],
		animation: .snappy
	) private var _signedApps: FetchedResults<Signed>
	
	@FetchRequest(
		entity: Imported.entity(),
		sortDescriptors: [NSSortDescriptor(keyPath: \Imported.date, ascending: false)],
		animation: .snappy
	) private var _importedApps: FetchedResults<Imported>
	
	// MARK: Body
    var body: some View {
		NBNavigationView("Library") {
			List {
				if
					_selectedScope == .all ||
					_selectedScope == .signed
				{
					NBSection(
						"Signed",
						secondary: _filteredSignedApps.count.description
					) {
						ForEach(_filteredSignedApps, id: \.uuid) { app in
							LibraryCellView(
								app: app,
								selectedInfoAppPresenting: $_selectedInfoAppPresenting,
								selectedSigningAppPresenting: $_selectedSigningAppPresenting,
								selectedInstallAppPresenting: $_selectedInstallAppPresenting
							)
							.compatMatchedTransitionSource(id: app.uuid ?? "", ns: _namespace)
						}
					}
				}
				
				if
					_selectedScope == .all ||
					_selectedScope == .imported
				{
					NBSection(
						"Imported",
						secondary: _filteredImportedApps.count.description
					) {
						ForEach(_filteredImportedApps, id: \.uuid) { app in
							LibraryCellView(
								app: app,
								selectedInfoAppPresenting: $_selectedInfoAppPresenting,
								selectedSigningAppPresenting: $_selectedSigningAppPresenting,
								selectedInstallAppPresenting: $_selectedInstallAppPresenting
							)
							.compatMatchedTransitionSource(id: app.uuid ?? "", ns: _namespace)
						}
					}
				}
			}
			.listStyle(.plain)
			.searchable(text: $_searchText, placement: .navigationBarDrawer(displayMode: .always))
			.compatSearchScopes($_selectedScope) {
				ForEach(Scope.allCases) { scope in
					Text(scope.rawValue).tag(scope)
				}
			}
			.toolbar {
				NBToolbarMenu(
					"Filter",
					systemImage: "line.3.horizontal.decrease",
					style: .icon,
					placement: .topBarTrailing,
					alignment: .trailing
				) {
					_sortActions()
				}
				
				NBToolbarMenu(
					"Import",
					systemImage: "plus",
					style: .icon,
					placement: .topBarTrailing
				) {
					Button("Import from Files") {
						_isImportingPresenting = true
					}
				}
			}
			.sheet(item: $_selectedInfoAppPresenting) { app in
				LibraryInfoView(app: app.base)
			}
			.sheet(item: $_selectedInstallAppPresenting) { app in
				InstallPreviewView(app: app.base, isSharing: app.archive)
					.presentationDetents([.height(200)])
					.presentationDragIndicator(.visible)
					.compatPresentationRadius(21)
			}
			.fullScreenCover(item: $_selectedSigningAppPresenting) { app in
				SigningView(app: app.base)
					.compatNavigationTransition(id: app.base.uuid ?? "", ns: _namespace)
			}
			.sheet(isPresented: $_isImportingPresenting) {
				FileImporterRepresentableView(
					allowedContentTypes:  [.ipa, .tipa],
					onDocumentsPicked: { urls in
						guard let selectedFileURL = urls.first else { return }
						FR.handlePackageFile(selectedFileURL) { _ in }
					}
				)
			}
        }
    }
}

// MARK: - Extension: View
extension LibraryView {
	enum Scope: String, CaseIterable, Identifiable {
		case all = "All"
		case signed = "Signed"
		case imported = "Imported"
		var id: String { rawValue }
	}
	
	enum SortOption: String, CaseIterable, Identifiable {
		case date = "Date"
		case name = "Name"
		var id: String { rawValue }
	}
	
	@ViewBuilder
	private func _sortActions() -> some View {
		Section("Filter by") {
			Button {
				if _sortOption == .date {
					_sortAscending.toggle()
				} else {
					_sortOption = .date
				}
			} label: {
				HStack {
					Text("Date")
					Spacer()
					if _sortOption == .date {
						Image(systemName: _sortAscending ? "chevron.up" : "chevron.down")
					}
				}
			}
			
			Button {
				if _sortOption == .name {
					_sortAscending.toggle()
				} else {
					_sortOption = .name
				}
			} label: {
				HStack {
					Text("Name")
					Spacer()
					if _sortOption == .name {
						Image(systemName: _sortAscending ? "chevron.up" : "chevron.down")
					}
				}
			}
		}
	}
}
