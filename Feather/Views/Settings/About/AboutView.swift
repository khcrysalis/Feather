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
	@State private var isLoading = false
	
	private let _creditsUrl = "https://raw.githubusercontent.com/khcrysalis/project-credits/refs/heads/main/feather/creditsv2.json"
	private let _donatorsUrl = "https://raw.githubusercontent.com/khcrysalis/project-credits/refs/heads/main/sponsors/credits.json"
	
	// MARK: Body
	var body: some View {
		Form {
			Section {
				LabeledContent("Name", value: Bundle.main.exec)
				LabeledContent("Version", value: Bundle.main.version)
			}
			
			if !_credits.isEmpty {
				NBSection("Credits") {
					ForEach(_credits, id: \.self) { credit in
						_credit(name: credit.name, desc: credit.desc, github: credit.github)
					}
				}
			}
			
			if !_donators.isEmpty {
				NBSection("Sponsors") {
					Text(try! AttributedString(markdown: _donators.map {
						"[\($0.name ?? $0.github)](https://github.com/\($0.github))"
					}.joined(separator: ", ")))
					
					Text("💜 This couldn't of been done without my sponsors!")
						.foregroundStyle(.secondary)
						.padding(.vertical, 2)
				}
			}
		}
		.navigationTitle("About")
		.navigationBarTitleDisplayMode(.inline)
		.task {
			await _fetchAllData()
		}
	}
	
	private func _fetchAllData() async {
		isLoading = true
		let dataService = _dataService
		
		await withTaskGroup(of: (String, CreditsDataHandler).self) { group in
			group.addTask { return await _fetchCredits(self._creditsUrl, using: dataService) }
			group.addTask { return await _fetchCredits(self._donatorsUrl, using: dataService) }
			
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
		let type = urlString == _creditsUrl ? "credits" : "donators"
		
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
