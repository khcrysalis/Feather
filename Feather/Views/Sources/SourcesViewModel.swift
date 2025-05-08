//
//  SourcesViewModel.swift
//  Feather
//
//  Created by samara on 30.04.2025.
//

import Foundation
import AltSourceKit
import SwiftUI
import NimbleJSON

// MARK: - Class
final class SourcesViewModel: ObservableObject {
	static let shared = SourcesViewModel()
	
	typealias RepositoryDataHandler = Result<ASRepository, Error>
	
	private let _dataService = NBFetchService()
	
	var isFinished = true
	@Published var sources: [AltSource: ASRepository] = [:]
	
	func fetchSources(_ sources: FetchedResults<AltSource>, refresh: Bool = false) async {
		guard isFinished else { return }
		
		// check if sources to be fetched are the same as before, if yes, return
		// also skip check if refresh is true
		if !refresh, sources.allSatisfy({ self.sources[$0] != nil }) { return }
		
		// isfinished is used to prevent multiple fetches at the same time
		isFinished = false
		defer { isFinished = true }
		
		await MainActor.run {
			self.sources = [:]
		}
		
		await withTaskGroup(
			of: (AltSource, ASRepository?).self,
			returning: Void.self
		) { group in
			for source in sources {
				group.addTask {
					guard let url = source.sourceURL else {
						return (source, nil)
					}
					
					return await withCheckedContinuation { continuation in
						self._dataService.fetch(from: url) { (result: RepositoryDataHandler) in
							switch result {
							case .success(let repo):
								continuation.resume(returning: (source, repo))
							case .failure(_):
								continuation.resume(returning: (source, nil))
							}
						}
					}
				}
			}
			
			for await tuple in group {
				let (source, repo) = tuple
				await MainActor.run {
					if let repo {
						self.sources[source] = repo
					}
				}
			}
		}
	}
}
