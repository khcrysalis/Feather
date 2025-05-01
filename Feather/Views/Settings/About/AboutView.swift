//
//  AboutView.swift
//  Feather
//
//  Created by samara on 30.04.2025.
//

import SwiftUI
import NimbleViews

// MARK: - View
struct AboutView: View {
	private let _kDonations = "https://github.com/sponsors/khcrysalis"
	private let _kGithub = "https://github.com/khcrysalis"
	private let _kTwitter = "https://twitter.com/khcrysalis"
	
	// MARK: Body
	var body: some View {
		Form {
			_profile()
		}
		.navigationTitle("About")
		.navigationBarTitleDisplayMode(.inline)
	}
	
	@ViewBuilder
	private func _profile() -> some View {
		NBSection("My Socials") {
			HStack(spacing: 12) {
				AsyncImage(url: URL(string: "\(_kGithub).png")) { image in
					image
						.resizable()
						.aspectRatio(contentMode: .fill)
				} placeholder: {
					Color.gray.opacity(0.3)
				}
				.frame(width: 48, height: 48)
				.clipShape(Circle())
				
				VStack(alignment: .leading, spacing: 2) {
					Text("samsam")
						.font(.headline)
					Text("@khcrysalis")
						.font(.subheadline)
						.foregroundColor(.secondary)
				}
			}
			.padding(.vertical, 4)
			
			Button("Github", systemImage: "arrow.up.right") {
				UIApplication.open(_kGithub)
			}
			
			Button("Donate", systemImage: "arrow.up.right") {
				UIApplication.open(_kDonations)
			}
			
			Button("Twitter", systemImage: "arrow.up.right") {
				UIApplication.open(_kTwitter)
			}
		}
	}
}
