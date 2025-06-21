//
//  SourcesAddView.swift
//  Feather
//
//  Created by samara on 1.05.2025.
//

import SwiftUI
import NimbleViews
import AltSourceKit
import NimbleJSON
import OSLog
import UIKit.UIImpactFeedbackGenerator

// MARK: - View
struct SourcesAddView: View {
	@Environment(\.dismiss) var dismiss
	
	typealias RepositoryDataHandler = Result<ASRepository, Error>
	
	private let _dataService = NBFetchService()
	
	@State private var _isImporting = false
	@State private var _sourceURL = ""
	
	// MARK: Body
	var body: some View {
		NBNavigationView(.localized("Add Source"), displayMode: .inline) {
			Form {
				Section {
					TextField(.localized("Source Repo URL"), text: $_sourceURL)
						.keyboardType(.URL)
						.textInputAutocapitalization(.never)
				} footer: {
					Text(.localized("Enter a URL to start validation."))
				}
				
				Section {
					Button(.localized("Import"), systemImage: "square.and.arrow.down") {
						_isImporting = true
						_addCode(UIPasteboard.general.string) {
							dismiss()
						}
					}
					
					Button(.localized("Export"), systemImage: "doc.on.doc") {
						UIPasteboard.general.string = Storage.shared.getSources().map {
							$0.sourceURL!.absoluteString
						}.joined(separator: "\n")
						UINotificationFeedbackGenerator().notificationOccurred(.success)
					}
				} footer: {
					Text(.localized("Supports importing from KravaSign/MapleSign and ESign"))
				}
			}
			.toolbar {
				NBToolbarButton(role: .cancel)
				
				if !_isImporting {
					NBToolbarButton(
						.localized("Save"),
						style: .text,
						placement: .confirmationAction,
						isDisabled: _sourceURL.isEmpty
					) {
						FR.handleSource(_sourceURL) {
							dismiss()
						}
					}
				} else {
					ToolbarItem(placement: .confirmationAction) {
						ProgressView()
					}
				}
			}
		}
	}
	
	private func _addCode(
		_ code: String?,
		competion: @escaping () -> Void
	) {
		guard let code else { return }
		
		let handler = ASDeobfuscator(with: code)
		let repoUrls = handler.decode().compactMap { URL(string: $0) }

		guard !repoUrls.isEmpty else { return }
		
		actor RepositoryCollector {
			private var repositories: [URL: ASRepository] = [:]
			
			func add(url: URL, repository: ASRepository) {
				repositories[url] = repository
			}
			
			func getAllRepositories() -> [URL: ASRepository] {
				return repositories
			}
		}
		
		let dataService = _dataService
		let collector = RepositoryCollector()
		
		Task {
			await withTaskGroup(of: Void.self) { group in
				for url in repoUrls {
					group.addTask {
						await withCheckedContinuation { continuation in
							Task { @MainActor in
								dataService.fetch<ASRepository>(from: url) { (result: RepositoryDataHandler) in
									switch result {
									case .success(let data):
										Task {
											await collector.add(url: url, repository: data)
										}
									case .failure(let error):
										Logger.misc.error("Failed to fetch \(url): \(error)")
									}
									continuation.resume()
								}
							}
						}
					}
				}
				
				await group.waitForAll()
			}
			
			let repositories = await collector.getAllRepositories()
			
			await MainActor.run {
				Storage.shared.addSources(repos: repositories) { _ in
					competion()
				}
			}
		}
	}
}
