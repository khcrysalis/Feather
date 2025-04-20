//
//  SourcesView.swift
//  Feather
//
//  Created by samara on 10.04.2025.
//

import CoreData
import SwiftUI

struct SourcesView: View {
	@Environment(\.managedObjectContext) private var viewContext

	@FetchRequest(
		entity: AltSource.entity(),
		sortDescriptors: [
			NSSortDescriptor(keyPath: \AltSource.name, ascending: false)
		],
		animation: .snappy
	) private var sources: FetchedResults<AltSource>

	@StateObject private var vm = SourcesViewModel()

	@State private var addingSource = false
	@State private var addingSourceLoading = false
	@State private var sourceURL = ""
	@State private var addingSourceError: Error?
	var body: some View {
		FRNavigationView("Sources") {
			List {
				ForEach(sources) { source in
					let repo = vm.sources[source]  // if it exists
					let status = vm.status[source] ?? .loading  // probably exists, doesn't matter
					NavigationLink(value: repo) {
						HStack {
							if let iconURL = source.iconURL {
								AsyncImage(url: iconURL) { image in
									image
										.resizable()
										.scaledToFit()
										.frame(width: 40, height: 40)
								} placeholder: {
									Image("App_Unknown")
										.resizable()
										.scaledToFit()
										.frame(width: 40, height: 40)
								}
							}
							Text(repo?.name ?? source.name ?? "Unknown")
								.font(.headline)
								.padding(.vertical, 4)
							switch status {
							case .ready: EmptyView()
							case .loading: ProgressView()
							case .error(let error):
								Image(systemName: "exclamationmark.triangle.fill")
									.foregroundColor(.red)
									.imageScale(.small)
							}
						}
					}
				}
			}
			.toolbar {
				ToolbarItem(placement: .navigationBarTrailing) {
					Button {
						addingSource.toggle()
					} label: {
						if addingSourceLoading {
							ProgressView()
						} else {
							Image(systemName: "plus.circle.fill")
						}
					}
					.disabled(addingSourceLoading)
				}
			}
			.alert("Add Source", isPresented: $addingSource) {
				TextField("Source URL", text: $sourceURL)
					.keyboardType(.URL)

				Button("Cancel", role: .cancel) {
					sourceURL = ""
				}
				Button("Add") {
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

							var repositories: [URL: Repository] = [:]
							for url in urls {
								let (data, _) = try await URLSession.shared.data(from: url)
								let decoder = JSONDecoder()
								let repo = try decoder.decode(Repository.self, from: data)
								repositories[url] = repo
							}

							Storage.shared.addSources(repos: repositories) { error in
								addingSourceError = error
							}
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
			.refreshable {
				await vm.fetchSources(sources, refresh: true)
			}
		}
		.task(id: Array(sources)) {
			await vm.fetchSources(sources)
		}
	}
}

final class SourcesViewModel: ObservableObject {
	var isFinished = true
	@Published var sources: [AltSource: Repository] = [:]
	@Published var status: [AltSource: RepoStatus] = [:]

	func fetchSources(_ sources: FetchedResults<AltSource>, refresh: Bool = false)
		async
	{
		guard isFinished else { return }

		// check if sources to be fetched are the same as before, if yes, return
		// also skip check if refresh is true
		if !refresh, sources.allSatisfy({ self.sources[$0] != nil }) { return }

		// isfinished is used to prevent multiple fetches at the same time
		isFinished = false
		defer { isFinished = true }

		await MainActor.run {
			self.sources = [:]
			// set loading status for all sources
			for source in sources {
				self.status[source] = .loading
			}
		}

		// remove statuses for sources that dont exist anymore
		await MainActor.run {
			self.status = self.status.filter { source in
				sources.contains(where: { $0.identifier == source.key.identifier })
			}
		}

		// fetch all sources
		await withTaskGroup(
			of: (RepoStatus, AltSource, Repository?).self,
			returning: Void.self
		) { group in
			for source in sources {
				group.addTask {
					let url = source.sourceURL!
					let req = URLRequest(url: url)
					do {
						let (data, _) = try await URLSession.shared.data(for: req)
						let decoder = JSONDecoder()
						let dateFormatter = DateFormatter()
						dateFormatter.dateFormat = "yyyy-MM-dd"
						decoder.dateDecodingStrategy = .formatted(dateFormatter)

						let repo = try decoder.decode(Repository.self, from: data)

						return (.ready, source, repo)
					} catch {
						return (.error(error), source, nil)
					}
				}
			}

			for await tuple in group {
				let (status, source, repo) = tuple
				await MainActor.run {
					if let repo {
						self.sources[source] = repo
					}
					self.status[source] = status
				}
			}
		}
	}

	enum RepoStatus {
		case ready
		case loading
		case error(Error)
	}
}
