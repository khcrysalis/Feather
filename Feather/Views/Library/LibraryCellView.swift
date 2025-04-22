//
//  LibraryAppIconView.swift
//  Feather
//
//  Created by samara on 11.04.2025.
//

import SwiftUI

// MARK: - View
struct LibraryCellView: View {
	@State var showActionSheet = false
	
	var app: AppInfoPresentable
	@Binding var selectedInfoApp: AnyApp?
	@Binding var selectedSigningApp: AnyApp?
	
	// MARK: Body
	var body: some View {
		HStack(spacing: 9) {
			FRAppIconView(app: app, size: 57, cornerRadius: 14)
			
			VStack(alignment: .leading, spacing: 2) {
				Text(app.name ?? "Unknown App")
					.font(.headline)
				
				Group {
					if let version = app.version, let id = app.identifier {
						Text("\(version) • \(id)")
					}
				}
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
		Button(role: .destructive) {
			Storage.shared.deleteApp(for: app)
		} label: {
			Label("Delete", systemImage: "trash")
		}
	}
	
	@ViewBuilder
	private func _contextActions(for app: AppInfoPresentable) -> some View {
		Button {
			selectedInfoApp = AnyApp(base: app)
		} label: {
			Label("Get Info", systemImage: "info.circle")
		}
	}
	
	@ViewBuilder
	private func _contextActionsExtra(for app: AppInfoPresentable) -> some View {
		if app.isSigned {
			if let id = app.identifier {
				Button {
					UIApplication.openApp(with: id)
				} label: {
					Label("Open", systemImage: "app.badge.checkmark")
				}
			}
			Button {
				selectedSigningApp = AnyApp(base: app)
			} label: {
				Label("Resign", systemImage: "signature")
			}
			Button {
			} label: {
				Label("Export", systemImage: "square.and.arrow.up")
			}
		} else {
			Button {

			} label: {
				Label("Install", systemImage: "square.and.arrow.down")
			}
		}
	}
	
	@ViewBuilder
	private func _buttonActions(for app: AppInfoPresentable) -> some View {
		Group {
			if app.isSigned {
				Button {
					
				} label: {
					_buttonLabel("Install")
				}
			} else {
				Button {
					selectedSigningApp = AnyApp(base: app)
				} label: {
					_buttonLabel("Sign")
				}
			}
		}
		.buttonStyle(.borderless)
	}
	
	@ViewBuilder
	private func _buttonLabel(_ title: String) -> some View {
		LRActionButton(
			title,
			systemImage: "",
			style: .text
		)
	}
}
