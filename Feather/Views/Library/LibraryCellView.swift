//
//  LibraryAppIconView.swift
//  Feather
//
//  Created by samara on 11.04.2025.
//

import SwiftUI

struct LibraryCellView: View {
	var app: Imported
	@Binding var selectedApp: Imported?

	var body: some View {
		HStack(spacing: 9) {
			_appIconView(for: app)
			
			VStack(alignment: .leading, spacing: 2) {
				Text(app.name ?? "Unknown App")
					.font(.headline)
				
				Group {
					if let version = app.version, let id = app.identifier {
						Text("\(version) • \(id)")
					} else {
						Text(app.identifier ?? "No Identifier")
					}
				}
				.font(.caption)
				.foregroundStyle(.secondary)
			}
		}
		.frame(maxWidth: .infinity, alignment: .leading)
		.swipeActions {
			_actions(for: app)
		}
		.contextMenu {
			_contextActions(for: app)
			Divider()
			_actions(for: app)
		}
	}
	
	@ViewBuilder
	private func _actions(for app: Imported) -> some View {
		Button(role: .destructive) {
			Storage.shared.deleteImported(for: app)
		} label: {
			Label("Delete", systemImage: "trash")
		}
	}
	
	@ViewBuilder
	private func _contextActions(for app: Imported) -> some View {
		Button {
			selectedApp = app
		} label: {
			Label("Get Info", systemImage: "info.circle")
		}
	}
	
	@ViewBuilder
	private func _appIconView(for app: Imported) -> some View {
		if
			let iconFilePath = Storage.shared.getAppDirectory(for: app)?.appendingPathComponent(app.icon ?? ""),
			let uiImage = UIImage(contentsOfFile: iconFilePath.path)
		{
			Image(uiImage: uiImage)
				.appIconStyle()
		} else {
			Image(systemName: "app.fill")
				.appIconStyle()
		}
	}
}
