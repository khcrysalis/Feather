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
	
	var object: AltSource
	@ObservedObject var viewModel: SourcesViewModel
	@State private var source: ASRepository?
	
	// MARK: Body
	var body: some View {
		Group {
			if isLoading {
				ProgressView("Loading...")
			} else if let source = source {
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
				Section("Filter by") {
					
				}
			}
		}
		.navigationBarTitleDisplayMode(.inline)
		.onAppear(perform: loadSourceData)
		.onChange(of: viewModel.sources[object]) { _ in
			loadSourceData()
		}
	}
	
	private func loadSourceData() {
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
