//
//  SettingsAltIconView.swift
//  feather
//
//  Created by samara on 18.01.2025.
//

import SwiftUI

struct SettingsAltIconView: View {
	@Environment(\.dismiss) var dismiss
	
	private let mainOptions: SigningMainDataWrapper
	private let applicationPath: URL
	
	init(mainOptions: SigningMainDataWrapper, app: URL) {
		self.mainOptions = mainOptions
		self.applicationPath = app
	}
	
	var body: some View {
		NavigationView {
			ScrollView {
				LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 8)], spacing: 8) {
					if let defaultIcon = loadDefaultIcon() {
						IconButton(
							iconPath: defaultIcon,
							name: "Default",
							applicationPath: applicationPath,
							action: { 
								mainOptions.mainOptions.iconURL = nil
								dismiss()
								NotificationCenter.default.post(name: Notification.Name("reloadSigningController"), object: nil)
							}
						)
					}
					
					ForEach(loadAlternateIcons().sorted(by: { $0.key < $1.key }), id: \.key) { name, path in
						IconButton(
							iconPath: path,
							name: name,
							applicationPath: applicationPath,
							action: { 
								mainOptions.mainOptions.iconURL = UIImage(contentsOfFile: applicationPath.appendingPathComponent(path).path)
								dismiss()
								NotificationCenter.default.post(name: Notification.Name("reloadSigningController"), object: nil)
							}
						)
					}
				}
				.padding()
			}
			.navigationTitle("Alt Icons")
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				Button("Close") { dismiss() }
			}
		}
	}
}

extension SettingsAltIconView {
	// im not making this better, I may be reusing code but I dont carfe
	private func loadDefaultIcon() -> String? {
		guard let infoPlistPath = applicationPath.appendingPathComponent("Info.plist") as? URL,
			  let infoPlist = NSDictionary(contentsOf: infoPlistPath),
			  let iconDict = infoPlist["CFBundleIcons"] as? [String: Any],
			  let primaryIcon = iconDict["CFBundlePrimaryIcon"] as? [String: Any],
			  let files = primaryIcon["CFBundleIconFiles"] as? [String],
			  let iconPath = files.first else {
			return nil
		}
		return iconPath
	}
	
	private func loadAlternateIcons() -> [String: String] {
		guard let infoPlistPath = applicationPath.appendingPathComponent("Info.plist") as? URL,
			  let infoPlist = NSDictionary(contentsOf: infoPlistPath),
			  let iconDict = infoPlist["CFBundleIcons"] as? [String: Any],
			  let alternateIcons = iconDict["CFBundleAlternateIcons"] as? [String: [String: Any]] else {
			return [:]
		}
		
		var icons: [String: String] = [:]
		for (name, details) in alternateIcons {
			if let files = details["CFBundleIconFiles"] as? [String],
			   let iconPath = files.first {
				icons[name] = iconPath
			}
		}
		return icons
	}
}

private struct IconButton: View {
	let iconPath: String
	let name: String
	let applicationPath: URL
	let action: () -> Void
	
	var body: some View {
		Button(action: action) {
			VStack {
				Image(uiImage: UIImage(contentsOfFile: applicationPath.appendingPathComponent(iconPath).path) ?? UIImage())
					.resizable()
					.aspectRatio(contentMode: .fit)
					.frame(width: 60, height: 60)
					.clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
				Text(name)
					.font(.caption)
					.fontWeight(.bold)
					.lineLimit(2)
					.multilineTextAlignment(.center)
					.foregroundStyle(Color.primary)
			}
			.frame(maxWidth: .infinity, maxHeight: .infinity)
			.aspectRatio(1, contentMode: .fill)
		}
	}
}
