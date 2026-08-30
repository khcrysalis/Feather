//
//  AppIconView.swift
//  Feather
//
//  Created by samara on 19.06.2025.
//

import SwiftUI
import NimbleViews

// MARK: - View extension: Model
extension AppIconView {
	struct AltIcon: Identifiable {
		var displayName: String
		var author: String
		var key: String?
		var image: UIImage
		var id: String { key ?? displayName }
		
		init(displayName: String, author: String, key: String? = nil) {
			self.displayName = displayName
			self.author = author
			self.key = key
			self.image = altImage(key)
		}
	}
	
	static func altImage(_ name: String?) -> UIImage {
		let path = Bundle.main.bundleURL.appendingPathComponent((name ?? "AppIcon60x60") + "@2x.png")
		return UIImage(contentsOfFile: path.path) ?? UIImage()
	}
}

// MARK: - View
struct AppIconView: View {
	@Binding var currentIcon: String?
	
	// dont translate
	var sections: [String: [AltIcon]] = [
		"Main": [
			AltIcon(displayName: "Feather", author: "Samara", key: nil),
			AltIcon(displayName: "Feather (macOS)", author: "Samara", key: "V2Mac"),
			AltIcon(displayName: "Feather v1", author: "Samara", key: "V1"),
			AltIcon(displayName: "Feather v1 (macOS)", author: "Samara", key: "V1Mac"),
			AltIcon(displayName: "Feather v0", author: "Samara", key: "V0"),
			AltIcon(displayName: "Feather Donor", author: "Samara", key: "Donor")
		],
		"Wingio": [
			AltIcon(displayName: "Feather", author: "Wingio", key: "Wing"),
		],
		"Liquid Glass": [
			AltIcon(displayName: "Glass Feather v1", author: "CSantos", key: "GlassFeatherV1"),
			AltIcon(displayName: "Glass Feather v2", author: "CSantos", key: "GlassFeatherV2"),
			AltIcon(displayName: "Glass Feather v3", author: "CSantos", key: "GlassFeatherV3"),
			AltIcon(displayName: "Midnight Sky", author: "CSantos", key: "MidnightSky")
		]
	]
	var sectionOrder: [String] {
		var order = ["Main", "Wingio"]
		if #available(iOS 26.0, *) {
			order.append("Liquid Glass")
		}
		return order
	}
	
	// MARK: Body
	var body: some View {
		NBList(.localized("App Icon")) {
			ForEach(sectionOrder, id: \.self) { section in
				if let icons = sections[section] {
					NBSection(section) {
						ForEach(icons) { icon in
							_icon(icon: icon)
						}
					}
				}
			}
		}
		.onAppear {
			currentIcon = UIApplication.shared.alternateIconName
		}
	}
}

// MARK: - View extension
extension AppIconView {
	@ViewBuilder
	private func _icon(
		icon: AppIconView.AltIcon
	) -> some View {
		Button {
			UIApplication.shared.setAlternateIconName(icon.key) { _ in
				currentIcon = UIApplication.shared.alternateIconName
			}
		} label: {
			HStack(spacing: 18) {
				Image(uiImage: icon.image)
					.appIconStyle()
				
				NBTitleWithSubtitleView(
					title: icon.displayName,
					subtitle: icon.author,
					linelimit: 0
				)
				
				if currentIcon == icon.key {
					Image(systemName: "checkmark").bold()
				}
			}
		}
	}
}
