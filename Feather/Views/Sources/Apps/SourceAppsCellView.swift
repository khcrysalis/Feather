//
//  SourceAppsCellView.swift
//  Feather
//
//  Created by samara on 3.05.2025.
//

import SwiftUI
import AltSourceKit
import Combine

// thats a whole pharaghraph of codes
struct SourceAppsCellView: View {
	@ObservedObject var downloadManager = DownloadManager.shared
	@State private var _downloadProgress: Double = 0
	@State var cancellable: AnyCancellable? // Combine
	
	var currentDownload: Download? {
		downloadManager.getDownload(by: app.currentUniqueId)
	}
	
	var app: ASRepository.App
	
	var body: some View {
		HStack(spacing: 2) {
			FRIconCellView(
				title: app.currentName,
				subtitle: _appDescription(app: app),
				iconUrl: app.iconURL
			)
			_download()
		}
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
		
		if let download = downloadManager.getDownload(by: app.currentUniqueId) {
			_downloadProgress = download.progress
			
			let publisher = Publishers.CombineLatest3(
				download.$progress,
				download.$bytesDownloaded,
				download.$totalBytes
			)
			
			cancellable = publisher.sink { (progress, status, bytes) in
				self._downloadProgress = progress
			}
		}
	}
	
	private func _appDescription(app: ASRepository.App) -> String {
		let optionalComponents: [String?] = [
			app.currentVersion,
			app.subtitle ?? "An awesome application"
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
					
					Image(systemName: _downloadProgress >= 0.99 ? "checkmark" : "square.fill")
						.foregroundStyle(.tint)
						.font(.footnote).bold()
				}
				.onTapGesture {
					downloadManager.cancelDownload(currentDownload)
				}
				.compatTransition()
			} else {
				Button {
					if let url = app.currentDownloadUrl {
						_ = downloadManager.startDownload(from: url, id: app.currentUniqueId)
					}
				} label: {
					_buttonLabel("arrow.down")
				}
				.buttonStyle(.borderless)
				.simultaneousGesture(
					LongPressGesture(minimumDuration: 0.5)
						.onEnded { _ in
							// Custom long press action
							print("Long press triggered")
						}
				)
				.compatTransition()
			}
		}
		.animation(.easeInOut(duration: 0.3), value: currentDownload != nil)
	}
	
	@ViewBuilder
	private func _buttonLabel(_ systemImage: String) -> some View {
		Group {
			Image(systemName: systemImage)
				.foregroundStyle(.tint)
				.font(.footnote).bold()
		}
		.frame(width: 66, height: 29)
		.background(Color(uiColor: .quaternarySystemFill))
		.clipShape(Capsule())
	}
}
