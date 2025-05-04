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

	@FetchRequest(
		entity: AltSource.entity(),
		sortDescriptors: [NSSortDescriptor(keyPath: \AltSource.name, ascending: true)],
		animation: .snappy
	) private var sources: FetchedResults<AltSource>
	
	//let status = vm.status[source] ?? .loading
	
	// MARK: Body
	var body: some View {
		NBNavigationView("Sources") {
			List {
				NBSection("Repositories") {
					ForEach(sources) { source in
						NavigationLink {
							SourceAppsView(object: source, viewModel: viewModel)
						} label: {
							SourcesCellView(source: source)
						}
					}
				}
			}
			.listStyle(.plain)
			.searchable(text: .constant(""), placement: .navigationBarDrawer(displayMode: .always))
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
				await viewModel.fetchSources(sources, refresh: true)
			}
		}
		.task(id: Array(sources)) {
			await viewModel.fetchSources(sources)
		}
	}
}
