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
import NukeUI
import Combine

// MARK: - View
struct SourceAppsView: View {
	@StateObject var downloadManager = DownloadManager.shared
	
	@State private var _isDataAvailable = false
	
	@Namespace private var _namespace
	
	var cancellable: AnyCancellable? // Combine
	
	var object: AltSource
	@ObservedObject var viewModel: SourcesViewModel
	@State var source: ASRepository? = nil
	
	// MARK: Body
	var body: some View {
		ZStack {
			Group {
				if
					_isDataAvailable,
					let source = source
				{
					SourceAppsTableRepresentableView(
						object: object,
						source: source
					)
					.ignoresSafeArea()
				} else if !_isDataAvailable {
					ProgressView("Loading...")
				} else {
					Text("No data available.")
				}
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
		.onAppear {
			_sourceData()
		}
		.onChange(of: viewModel.sources[object]) { _ in
			_sourceData()
		}
	}
	
	private func _sourceData() {
		if let source_data = viewModel.sources[object] {
			source = source_data
			_isDataAvailable = true
		} else {
			_isDataAvailable = false
		}
	}
}
