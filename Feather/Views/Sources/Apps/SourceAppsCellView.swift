//
//  SourceAppsCellView.swift
//  Feather
//
//  Created by samara on 3.05.2025.
//

import SwiftUI
import AltSourceKit
import NimbleViews
import Combine
import NukeUI

// thats a whole pharaghraph of codes
struct SourceAppsCellView: View {
	@ObservedObject var downloadManager = DownloadManager.shared
	@AppStorage("Feather.storeCellAppearance") private var _storeCellAppearance: Int = 0
	
	@State private var _downloadProgress: Double = 0
	@State var cancellable: AnyCancellable? // Combine
	
	var currentDownload: Download? {
		downloadManager.getDownload(by: app.currentUniqueId)
	}
	
	var source: ASRepository
	var app: ASRepository.App
	
	var body: some View {
		VStack {
			HStack(spacing: 2) {
				FRIconCellView(
					title: app.currentName,
					subtitle: _appDescription(app: app),
					iconUrl: app.iconURL
				)
				.overlay(alignment: .bottomLeading) {
					if let iconURL = source.currentIconURL {
						LazyImage(url: iconURL) { state in
							if let image = state.image {
								image
									.appIconStyle(size: 20, isCircle: true, background: Color(uiColor: .secondarySystemBackground))
									.offset(x: 41, y: 4)
							}
						}
					}
				}
				_download()
			}
			
			if _storeCellAppearance != 0 {
				Text(app.localizedDescription ?? "")
					.frame(maxWidth: .infinity, alignment: .leading)
					.font(.subheadline)
					.foregroundStyle(.secondary)
					.lineLimit(18)
					.padding(.top, 2)
			}
		}
		.padding(.vertical, { if #available(iOS 19, *) { 6 } else { 0 } }())
		.onAppear(perform: _setupDownloadObserver)
		.onDisappear {
			cancellable?.cancel()
		}
		.onChange(of: downloadManager.downloads.description) { _ in
			_setupDownloadObserver()
		}
	}
	
	private func _setupDownloadObserver() {
		cancellable?.cancel()
		
		if let currentDownload {
			_downloadProgress = currentDownload.overallProgress
			
			let publisher = Publishers.CombineLatest(
				currentDownload.$progress,
				currentDownload.$unpackageProgress
			)
			
			cancellable = publisher.sink { _, _ in
				self._downloadProgress = currentDownload.overallProgress
			}
		}
	}
	
	private func _appDescription(app: ASRepository.App) -> String {
		let optionalComponents: [String?] = [
			app.currentVersion,
			app.subtitle ?? app.localizedDescription ?? .localized("An awesome application")
		]
		
		let components: [String] = optionalComponents.compactMap { value in
			guard
				let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines),
				!trimmed.isEmpty
			else {
				return nil
			}
			
			return trimmed
		}
		
		return components.joined(separator: " • ")
	}
}

extension SourceAppsCellView {
	@ViewBuilder
	private func _download() -> some View {
		ZStack {
			if let currentDownload {
				ZStack {
					Circle()
						.trim(from: 0, to: _downloadProgress)
						.stroke(Color.accentColor, style: StrokeStyle(lineWidth: 2.3, lineCap: .round))
						.rotationEffect(.degrees(-90))
						.frame(width: 29, height: 29)
						.animation(.smooth, value: _downloadProgress)
					
					Image(systemName: _downloadProgress >= 0.75 ? "archivebox" : "square.fill")
						.foregroundStyle(.tint)
						.font(.footnote).bold()
				}
				.onTapGesture {
					if _downloadProgress <= 0.75 {
						downloadManager.cancelDownload(currentDownload)
					}
				}
				.compatTransition()
			} else {
				Button {
					if let url = app.currentDownloadUrl {
						_ = downloadManager.startDownload(from: url, id: app.currentUniqueId)
					}
				} label: {
					NBButton(systemImage: "arrow.down", horizontalPadding: 0)
				}
				.buttonStyle(.borderless)
				.compatTransition()
			}
		}
		.animation(.easeInOut(duration: 0.3), value: currentDownload != nil)
	}
}
