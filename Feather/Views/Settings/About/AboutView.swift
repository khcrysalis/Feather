//
//  AboutView.swift
//  Feather
//
//  Created by samara on 30.04.2025.
//

import SwiftUI
import NimbleViews
import NimbleJSON

// MARK: - Extension: Model
extension AboutView {
	struct CreditsModel: Codable, Hashable {
		let name: String?
		let desc: String?
		let github: String
	}

	struct GithubRelease: Decodable {
		let tagName: String
		let htmlUrl: URL

		private enum CodingKeys: String, CodingKey {
			case tagName = "tag_name"
			case htmlUrl = "html_url"
		}
	}
}

// MARK: - View
struct AboutView: View {
	@State private var _credits: [CreditsModel] = [
		.init(name: "C", desc: "Developer", github: "claration"),
		.init(name: "Asami", desc: "Developer", github: "Nyasami"),
		.init(name: "Lakhan Lothiyi", desc: "AltStore Repositories", github: "llsc12"),
	]
	
	let pngURL = URL(string: "https://sponsors.claration.dev/sponsors.png")!
	
	private let _dataService = NBFetchService()
	private let _releasesApiUrl = "https://api.github.com/repos/claration/Feather/releases/latest"

	@State private var _latestFeatherRelease: GithubRelease?

	// MARK: Body
	var body: some View {
		NBList(.localized("About")) {
			Section {
				VStack {
					FRAppIconView(size: 72)
					
					Text(Bundle.main.exec)
						.font(.largeTitle)
						.bold()
						.foregroundStyle(Color.accentColor)
					
					HStack(spacing: 4) {
						Text(.localized("Version"))
						Text(Bundle.main.version)
					}
					.font(.footnote)
					.foregroundStyle(.secondary)

					if let release = _latestFeatherRelease {
						Button {
							UIApplication.open(release.htmlUrl)
						} label: {
							HStack(spacing: 4) {
								Image(systemName: "arrow.down.circle.fill")
								Text(verbatim: .localized("Update Available: %@", arguments: release.tagName))
							}
							.font(.footnote)
						}
						.padding(.top, 2)
					}
				}
			}
			.frame(maxWidth: .infinity)
			.listRowBackground(EmptyView())
			
			NBSection(.localized("Credits")) {
				ForEach(_credits, id: \.github) { credit in
					_credit(name: credit.name, desc: credit.desc, github: credit.github)
				}
				.transition(.slide)
			}
			
			NBSection(.localized("Sponsors")) {
				Text(.localized("💜 This couldn't of been done without my sponsors!"))
					.foregroundStyle(.secondary)
					.padding(.vertical, 2)
				AsyncImage(url: pngURL) { phase in
					switch phase {
					case .empty:
						ProgressView()
							.frame(maxWidth: .infinity)
							.frame(height: 120)
					case .success(let image):
						image
							.resizable()
							.scaledToFit()
							.frame(maxWidth: .infinity)
							.listRowInsets(EdgeInsets())
					case .failure:
						Image(systemName: "photo")
							.resizable()
							.scaledToFit()
							.frame(maxWidth: .infinity)
							.foregroundColor(.gray)
							.frame(height: 120)
						
					@unknown default:
						EmptyView()
					}
				}
			}
		}
		.onAppear(perform: _checkForUpdates)
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
		Button {
			UIApplication.open("https://github.com/\(github)")
		} label: {
			HStack {
				FRIconCellView(
					title: name ?? github,
					subtitle: desc ?? "",
					iconUrl: URL(string: "https://github.com/\(github).png")!,
					size: 45,
					isCircle: true
				)
				
				Image(systemName: "arrow.up.right")
					.foregroundColor(.secondary.opacity(0.65))
			}
		}
	}
}

// MARK: - Extension: update check
extension AboutView {
	private func _checkForUpdates() {
		_dataService.fetch(from: _releasesApiUrl) { (result: Result<GithubRelease, Error>) in
			guard
				case .success(let release) = result,
				_isVersion(release.tagName, newerThan: Bundle.main.version)
			else {
				return
			}

			DispatchQueue.main.async {
				_latestFeatherRelease = release
			}
		}
	}

	private func _isVersion(_ remote: String, newerThan local: String) -> Bool {
		let remoteVersion = remote.hasPrefix("v") ? String(remote.dropFirst()) : remote
		return remoteVersion.compare(local, options: .numeric) == .orderedDescending
	}
}
