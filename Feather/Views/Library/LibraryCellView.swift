//
//  LibraryAppIconView.swift
//  Feather
//
//  Created by samara on 11.04.2025.
//

import SwiftUI

struct LibraryCellView: View {
	var app: AppInfoPresentable
	@Binding var selectedApp: AnyApp?

	var body: some View {
		HStack(spacing: 9) {
			FRAppIconView(app: app, size: 54, cornerRadius: 13)
			
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
	private func _actions(for app: AppInfoPresentable) -> some View {
		Button(role: .destructive) {
			Storage.shared.deleteApp(for: app)
		} label: {
			Label("Delete", systemImage: "trash")
		}
	}
	
	@ViewBuilder
	private func _contextActions(for app: AppInfoPresentable) -> some View {
		Button {
			selectedApp = AnyApp(base: app)
		} label: {
			Label("Get Info", systemImage: "info.circle")
		}
	}
}
