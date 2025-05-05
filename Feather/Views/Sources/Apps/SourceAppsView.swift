//
//  SourceAppsView.swift
//  Feather
//
//  Created by samara on 1.05.2025.
//

import SwiftUI
import Esign
import NimbleViews
import UIKit

// MARK: - View
struct SourceAppsView: View {
	@State var isLoading = true
	@State var hasLoadedInitialData = false
	
	@State private var _searchText = ""
	@State private var _sortOption: SortOption = .default
	@State private var _sortAscending = true
	
	var object: AltSource
	@ObservedObject var viewModel: SourcesViewModel
	@State private var source: ASRepository?
	
	// MARK: Body
	var body: some View {
		Group {
			if isLoading {
				ProgressView("Loading...")
			} else if let source {
				SourceAppsTableRepresentableView(
					object: object,
					source: source,
					searchText: $_searchText,
					sortOption: $_sortOption,
					sortAscending: $_sortAscending
				)
				.ignoresSafeArea()
			} else {
				Text("No data available.")
			}
		}
		.navigationTitle(object.name ?? "Unknown")
		.searchable(text: $_searchText)
		.toolbarTitleMenu {
			if let url = source?.website {
				Button("Visit Website", systemImage: "globe") {
					UIApplication.open(url)
				}
			}
			
			if let url = source?.patreonURL {
				Button("Visit Patreon", systemImage: "dollarsign.circle") {
					UIApplication.open(url)
				}
			}
		}
		.toolbar {
			NBToolbarMenu(
				"Filter",
				systemImage: "line.3.horizontal.decrease",
				style: .icon,
				placement: .topBarTrailing
			) {
				_sortActions()
			}
		}
		.navigationBarTitleDisplayMode(.inline)
		.onAppear {
			if !hasLoadedInitialData {
				_load()
				hasLoadedInitialData = true
			}
		}
		.onChange(of: viewModel.sources[object]) { _ in
			_load()
		}
	}
	
	private func _load() {
		isLoading = true
		
		Task {
			if let sourceData = viewModel.sources[object] {
				source = sourceData
				isLoading = false
			} else {
				source = nil
				isLoading = false
			}
		}
	}
}

// MARK: - Extension: View (Sort)
extension SourceAppsView {
	@ViewBuilder
	private func _sortActions() -> some View {
		Section("Filter by") {
			ForEach(SortOption.allCases, id: \.displayName) { opt in
				_sortButton(for: opt)
			}
		}
	}
	
	private func _sortButton(for option: SortOption) -> some View {
		Button {
			if _sortOption == option {
				_sortAscending.toggle()
			} else {
				_sortOption = option
				_sortAscending = true
			}
		} label: {
			HStack {
				Text(option.displayName)
				Spacer()
				if _sortOption == option {
					Image(systemName: _sortAscending ? "chevron.up" : "chevron.down")
				}
			}
		}
	}
	
	enum SortOption: CaseIterable {
		case `default`, name, date
		
		var displayName: String {
			switch self {
			case .default: return "Default"
			case .name: return "Name"
			case .date: return "Date"
			}
		}
	}
}
