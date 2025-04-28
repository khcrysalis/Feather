//
//  LibraryAppIconView.swift
//  Feather
//
//  Created by samara on 11.04.2025.
//

import SwiftUI
import NimbleExtensions

// MARK: - View
struct LibraryCellView: View {
	var app: AppInfoPresentable
	@Binding var selectedInfoAppPresenting: AnyApp?
	@Binding var selectedSigningAppPresenting: AnyApp?
	@Binding var selectedInstallAppPresenting: AnyApp?
	
	// MARK: Body
	var body: some View {
		HStack(spacing: 9) {
			FRAppIconView(app: app, size: 57, cornerRadius: 14)
			
			VStack(alignment: .leading, spacing: 2) {
				Text(app.name ?? "Unknown")
					.font(.headline)
				
				Group {
					if
						let version = app.version,
						let id = app.identifier
					{
						Text("\(version) • \(id)")
					} else {
						Text("Unknown")
					}
				}
				.lineLimit(0)
				.font(.subheadline)
				.foregroundStyle(.secondary)
			}
			.frame(maxWidth: .infinity, alignment: .leading)
			
			_buttonActions(for: app)
		}
		
		.swipeActions {
			_actions(for: app)
		}
		.contextMenu {
			_contextActions(for: app)
			Divider()
			_contextActionsExtra(for: app)
			Divider()
			_actions(for: app)
		}
	}
}

// MARK: - Extension: View
extension LibraryCellView {
	@ViewBuilder
	private func _actions(for app: AppInfoPresentable) -> some View {
		Button("Delete", systemImage: "trash", role: .destructive) {
			Storage.shared.deleteApp(for: app)
		}
	}
	
	@ViewBuilder
	private func _contextActions(for app: AppInfoPresentable) -> some View {
		Button("Get Info", systemImage: "info.circle") {
			selectedInfoAppPresenting = AnyApp(base: app)
		}
	}
	
	@ViewBuilder
	private func _contextActionsExtra(for app: AppInfoPresentable) -> some View {
		if app.isSigned {
			if let id = app.identifier {
				Button("Open", systemImage: "app.badge.checkmark") {
					UIApplication.openApp(with: id)
				}
			}
			Button("Install", systemImage: "square.and.arrow.down") {
				selectedInstallAppPresenting = AnyApp(base: app)
			}
			Button("Re-sign", systemImage: "signature") {
				selectedSigningAppPresenting = AnyApp(base: app)
			}
			Button("Export", systemImage: "square.and.arrow.up") {
				selectedInstallAppPresenting = AnyApp(base: app, archive: true)
			}
		} else {
			Button("Install", systemImage: "square.and.arrow.down") {
				selectedInstallAppPresenting = AnyApp(base: app)
			}
		}
	}
	
	@ViewBuilder
	private func _buttonActions(for app: AppInfoPresentable) -> some View {
		Group {
			if app.isSigned {
				Button {
					selectedInstallAppPresenting = AnyApp(base: app)
				} label: {
					_buttonLabel("Install")
				}
			} else {
				Button {
					selectedSigningAppPresenting = AnyApp(base: app)
				} label: {
					_buttonLabel("Sign")
				}
			}
		}
		.buttonStyle(.borderless)
	}
	
	@ViewBuilder
	private func _buttonLabel(_ title: String) -> some View {
		Group {
			Text(title)
				.font(.footnote).bold()
		}
		.frame(width: 66, height: 29)
		.background(Color(uiColor: .quaternarySystemFill))
		.clipShape(Capsule())
	}
}
