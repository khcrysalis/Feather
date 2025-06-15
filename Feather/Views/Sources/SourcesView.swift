//
//  SourcesView.swift
//  Feather
//
//  Created by samara on 10.04.2025.
//

import CoreData
import AltSourceKit
import SwiftUI
import NimbleViews

// MARK: - View
struct SourcesView: View {
	@Environment(\.horizontalSizeClass) private var horizontalSizeClass
	
	@AppStorage("Feather.shouldStar") private var _shouldStar: Int = 0
	
	@StateObject var viewModel = SourcesViewModel.shared
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
		NBNavigationView(.localized("Sources")) {
			NBListAdaptable {
				Section {
					NavigationLink {
						SourceAppsView(object: Array(_sources), viewModel: viewModel)
					} label: {
						let isRegular = horizontalSizeClass != .compact
						HStack(spacing: 9) {
							Image("Repositories").appIconStyle()
							NBTitleWithSubtitleView(
								title: .localized("All Repositories"),
								subtitle: .localized("See all apps from your sources")
							)
						}
						.padding(isRegular ? 12 : 0)
						.background(
							isRegular
							? RoundedRectangle(cornerRadius: 18, style: .continuous)
								.fill(Color(.quaternarySystemFill))
							: nil
						)
					}
					.buttonStyle(.plain)
				}
				
				NBSection(
					.localized("Repositories"),
					secondary: _filteredSources.count.description
				) {
					ForEach(_filteredSources) { source in
						NavigationLink {
							SourceAppsView(object: [source], viewModel: viewModel)
						} label: {
							SourcesCellView(source: source)
						}
						.buttonStyle(.plain)
					}
				}
			}
			.searchable(text: $_searchText, placement: .platform())
			.toolbar {
				NBToolbarButton(
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
		.onAppear {
			guard _shouldStar < 6 else { return }; _shouldStar += 1
			guard _shouldStar == 6 else { return }
			
			let github = UIAlertAction(title: "GitHub", style: .default) { _ in
				UIApplication.open("https://github.com/khcrysalis/Feather")
			}
			
			let cancel = UIAlertAction(title: .localized("Dismiss"), style: .cancel)
			
			UIAlertController.showAlert(
				title: .localized("Enjoying %@?", arguments: Bundle.main.name),
				message: .localized("Go to our GitHub and give us a star!"),
				actions: [github, cancel]
			)
		}
	}
}
