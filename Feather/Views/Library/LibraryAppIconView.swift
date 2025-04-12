//
//  LibraryAppIconView.swift
//  Feather
//
//  Created by samara on 11.04.2025.
//

import SwiftUI

struct LibraryAppIconView: View {
	private var _app: Imported
	
	init(_ app: Imported) {
		self._app = app
	}
	
	var body: some View {
		HStack(spacing: 9) {
			_appIconView(for: _app)
			
			VStack(alignment: .leading, spacing: 2) {
				Text(_app.name ?? "Unknown App")
					.font(.headline)
				
				if let version = _app.version, let id = _app.identifier {
					Text("\(version) • \(id)")
						.font(.caption)
						.foregroundStyle(.secondary)
				} else {
					Text(_app.identifier ?? "No Identifier")
						.font(.caption)
						.foregroundStyle(.secondary)
				}
			}
			
			Spacer()
		}
		.swipeActions {
			_contextActions(for: _app)
		}
		.contextMenu {
			_contextActions(for: _app)
		}
	}
	
	@ViewBuilder
	private func _contextActions(for app: Imported) -> some View {
		Button(role: .destructive) {
			Storage.shared.deleteImported(for: _app)
		} label: {
			Label("Delete", systemImage: "trash")
		}
		.tint(.red)
	}
	
	@ViewBuilder
	private func _appIconView(for app: Imported) -> some View {
		if let iconFilePath = Storage.shared.getDirectory(for: app)?
			.appendingPathComponent(app.icon ?? ""),
		   let uiImage = UIImage(contentsOfFile: iconFilePath.path) {
			Image(uiImage: uiImage)
				.appIconStyle()
		} else {
			Image(systemName: "app.fill")
				.appIconStyle()
		}
	}
}
