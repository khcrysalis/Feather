//
//  SourcesView.swift
//  Feather
//
//  Created by samara on 10.04.2025.
//

import CoreData
import Esign
import SwiftUI
import NimbleViews

// MARK: - View
struct SourcesView: View {
	@Environment(\.managedObjectContext) var viewContext
	
	@StateObject var viewModel = SourcesViewModel()
	@State private var _isAddingPresenting = false
	@State private var _addingSourceLoading = false
	@State private var _searchText = ""
	
	private var _filteredSources: [AltSource] {
		_sources.filter { _searchText.isEmpty || ($0.name?.localizedCaseInsensitiveContains(_searchText) ?? false) }
	}
	
	@FetchRequest(
		entity: AltSource.entity(),
		sortDescriptors: [NSSortDescriptor(keyPath: \AltSource.name, ascending: true)],
		animation: .snappy
	) private var _sources: FetchedResults<AltSource>
	
	// MARK: Body
	var body: some View {
		NBNavigationView("Sources") {
			List {
				Section {
					NavigationLink {
						SourceAppsView(object: Array(_sources), viewModel: viewModel)
					} label: {
						HStack(spacing: 9) {
							Image("Repositories").appIconStyle()
							NBTitleWithSubtitleView(
								title: "All Repositories",
								subtitle: "See all apps from your sources"
							)
						}
					}
				}
				
				NBSection(
					"Repositories",
					secondary: _filteredSources.count.description
				) {
					ForEach(_filteredSources) { source in
						NavigationLink {
							SourceAppsView(object: [source], viewModel: viewModel)
						} label: {
							SourcesCellView(source: source)
						}
					}
				}
			}
			.listStyle(.plain)
			.searchable(text: $_searchText, placement: .navigationBarDrawer(displayMode: .always))
			.toolbar {
				NBToolbarButton(
					"Add",
					systemImage: "plus",
					style: .icon,
					placement: .topBarTrailing,
					isDisabled: _addingSourceLoading
				) {
					_isAddingPresenting = true
				}
			}
			.sheet(isPresented: $_isAddingPresenting) {
				SourcesAddView()
					.presentationDetents([.medium])
			}
			.refreshable {
				await viewModel.fetchSources(_sources, refresh: true)
			}
		}
		.task(id: Array(_sources)) {
			await viewModel.fetchSources(_sources)
		}
	}
}
