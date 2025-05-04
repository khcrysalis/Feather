//
//  SourcesAddView.swift
//  Feather
//
//  Created by samara on 1.05.2025.
//

import SwiftUI
import NimbleViews
import Esign

// MARK: - View
struct SourcesAddView: View {
	@Environment(\.dismiss) var dismiss
	
	@State private var addingSource = false
	@State private var addingSourceLoading = false
	@State private var sourceURL = ""
	@State private var addingSourceError: Error?
	
	#warning("add basic checks and obfuscated repositories")
	
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
			}
			.toolbar {
				NBToolbarButton(role: .cancel)
				
				NBToolbarButton(
					"Save",
					systemImage: "checkmark",
					style: .text,
					placement: .confirmationAction
				) {
					Task {
						addingSourceLoading = true
						defer { addingSourceLoading = false }
						do {
							
							let urls = sourceURL.components(separatedBy: " ").compactMap({
								URL(string: $0)
							})
							guard urls.allSatisfy({ $0.scheme?.contains("http") == true })
							else {
								throw URLError(.badURL)
							}
							
							sourceURL = ""
							
							var repositories: [URL: ASRepository] = [:]
							for url in urls {
								let (data, _) = try await URLSession.shared.data(from: url)
								let decoder = JSONDecoder()
								let repo = try decoder.decode(ASRepository.self, from: data)
								repositories[url] = repo
							}
							
							Storage.shared.addSources(repos: repositories) { error in
								addingSourceError = error
							}
							
							dismiss()
						} catch {
							addingSourceError = error
						}
					}
				}
			}
			.alert(
				"Error",
				isPresented: .init(
					get: { self.addingSourceError != nil },
					set: { _ in self.addingSourceError = nil }
				)
			) {
				Button("OK", role: .cancel) {}
			} message: {
				if let error = addingSourceError {
					Text(error.localizedDescription + "\n\n" + String(reflecting: error))
				} else {
					Text("An unknown error occurred.")
				}
			}
		}
    }
	
	private func _add() {
		
	}
	
}

