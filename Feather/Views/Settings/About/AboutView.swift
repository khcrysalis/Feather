//
//  AboutView.swift
//  Feather
//
//  Created by samara on 30.04.2025.
//

import SwiftUI
import NimbleViews
import NimbleJSON

// MARK: - View
struct AboutView: View {
	typealias CreditsDataHandler = Result<[CreditsModel], Error>
	private let _dataService = NBFetchService()
	
	@State private var _credits: [CreditsModel] = []
	@State private var _donators: [CreditsModel] = []
	@State var isLoading = true
	
	private let _creditsUrl = "https://raw.githubusercontent.com/khcrysalis/project-credits/refs/heads/main/feather/creditsv2.json"
	private let _donatorsUrl = "https://raw.githubusercontent.com/khcrysalis/project-credits/refs/heads/main/sponsors/credits.json"
	
	// MARK: Body
	var body: some View {
		NBList(.localized("About")) {
			Section {
				LabeledContent(.localized("Name"), value: Bundle.main.exec)
				LabeledContent(.localized("Version"), value: Bundle.main.version)
			}
			
			NBSection(.localized("Credits")) {
				if !_credits.isEmpty {
					ForEach(_credits, id: \.self) { credit in
						_credit(name: credit.name, desc: credit.desc, github: credit.github)
					}
					.transition(.slide)
				}
			}
			
			NBSection(.localized("Sponsors")) {
				if !_donators.isEmpty {
					Group {
						Text(try! AttributedString(markdown: _donators.map {
							"[\($0.name ?? $0.github)](https://github.com/\($0.github))"
						}.joined(separator: ", ")))
						
						Text(.localized("💜 This couldn't of been done without my sponsors!"))
							.foregroundStyle(.secondary)
							.padding(.vertical, 2)
					}
					.transition(.slide)
				}
			}
		}
		.animation(.default, value: isLoading)
		.task {
			await _fetchAllData()
		}
	}
	
	private func _fetchAllData() async {
		await withTaskGroup(of: (String, CreditsDataHandler).self) { group in
			group.addTask { return await _fetchCredits(self._creditsUrl, using: _dataService) }
			group.addTask { return await _fetchCredits(self._donatorsUrl, using: _dataService) }
			
			for await (type, result) in group {
				await MainActor.run {
					switch result {
					case .success(let data):
						if type == "credits" {
							self._credits = data
						} else {
							self._donators = data
						}
					case .failure(_): break
					}
				}
			}
		}
		
		await MainActor.run {
			isLoading = false
		}
	}
	
	private func _fetchCredits(_ urlString: String, using service: NBFetchService) async -> (String, CreditsDataHandler) {
		let type = urlString == _creditsUrl 
		? "credits"
		: "donators"
		
		return await withCheckedContinuation { continuation in
			service.fetch(from: urlString) { (result: CreditsDataHandler) in
				continuation.resume(returning: (type, result))
			}
		}
	}
}

// MARK: - Extension: view
extension AboutView {
	@ViewBuilder
	private func _credit(
		name: String?,
		desc: String?,
		github: String
	) -> some View {
		FRIconCellView(
			title: name ?? github,
			subtitle: desc ?? "",
			iconUrl: URL(string: "https://github.com/\(github).png")!
		)
	}
}
