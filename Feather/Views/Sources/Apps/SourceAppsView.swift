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
	
	@State private var _sortOption: SortOption = .date
	@State private var _sortAscending = false
	
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
					source: source
				)
				.ignoresSafeArea()
			} else {
				Text("No data available.")
			}
		}
		.navigationTitle(object.name ?? "Unknown")
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
				"Options",
				systemImage: "ellipsis",
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

// MARK: - Extension: View
extension SourceAppsView {
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
