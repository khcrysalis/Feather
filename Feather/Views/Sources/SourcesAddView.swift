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

// MARK: - View
struct SourcesAddView: View {
	@Environment(\.dismiss) var dismiss
	
	typealias RepositoryDataHandler = Result<ASRepository, Error>
	
	private let _dataService = NBFetchService()
	
	@State private var addingSource = false
	@State private var sourceURL = ""
		
	// MARK: Body
    var body: some View {
		NBNavigationView("Add Source", displayMode: .inline) {
			Form {
				NBSection("Source") {
					TextField("Source Repo URL", text: $sourceURL)
						.keyboardType(.URL)
				} footer: {
					Text("Enter a URL to start validation.")
				}
				
				Section {
					Button("Import", systemImage: "square.and.arrow.down") {
						_addCode(UIPasteboard.general.string)
					}
					
					Button("Export", systemImage: "doc.on.clipboard") {
						UIPasteboard.general.string = Storage.shared.getSources().map {
							$0.sourceURL!.absoluteString
						}.joined(separator: "\n")
					}
				}
			}
			.toolbar {
				NBToolbarButton(role: .cancel)
				
				NBToolbarButton(
					"Save",
					systemImage: "checkmark",
					style: .text,
					placement: .confirmationAction,
					isDisabled: sourceURL.isEmpty
				) {
					_add(sourceURL)
				}
			}
		}
    }
	
	private func _add(_ urlString: String) {
		guard let url = URL(string: urlString) else { return }
		
		_dataService.fetch<ASRepository>(from: url) { (result: RepositoryDataHandler) in
			switch result {
			case .success(let data):
				let id = data.id ?? url.absoluteString
				
				if !Storage.shared.sourceExists(id) {
					Storage.shared.addSource(url, repository: data, id: id) { _ in
						dismiss()
					}
				} else {
					DispatchQueue.main.async {
						UIAlertController.showAlertWithOk(title: "Error", message: "Repository already added.")
					}
				}
			case .failure(let error):
				DispatchQueue.main.async {
					UIAlertController.showAlertWithOk(title: "Error", message: error.localizedDescription)
				}
			}
		}
	}
	
	private func _addCode(_ code: String?) {
		guard let code else { return }
		
		let handler = ASDeobfuscator(with: code)
		let repoUrls = handler.decode().compactMap { URL(string: $0) }

		print(repoUrls)
		
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
										print("Failed to fetch \(url): \(error)")
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
					dismiss()
				}
			}
		}
	}}

