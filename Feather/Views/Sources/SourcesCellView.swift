//
//  SourcesCellView.swift
//  Feather
//
//  Created by samara on 1.05.2025.
//

import SwiftUI
import NimbleViews
import NukeUI

// MARK: - View
struct SourcesCellView: View {
	var source: AltSource
	
	// MARK: Body
	var body: some View {
		FRIconCellView(
			title: source.name ?? "Unknown",
			subtitle: source.sourceURL?.absoluteString ?? "",
			iconUrl: source.iconURL
		)
		.swipeActions {
			_actions(for: source)
			_contextActions(for: source)
		}
		.contextMenu {
			_contextActions(for: source)
			Divider()
			_actions(for: source)
		}
	}
}

// MARK: - Extension: View
extension SourcesCellView {
	@ViewBuilder
	private func _actions(for source: AltSource) -> some View {
		Button("Delete", systemImage: "trash", role: .destructive) {
			Storage.shared.deleteSource(for: source)
		}
	}
	
	@ViewBuilder
	private func _contextActions(for source: AltSource) -> some View {
		Button("Copy", systemImage: "doc.on.doc") {
			UIPasteboard.general.string = source.sourceURL?.absoluteString
		}
		.tint(.accentColor)
	}
}
