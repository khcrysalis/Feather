//
//  LibraryAppIconView.swift
//  Feather
//
//  Created by samara on 11.04.2025.
//

import SwiftUI
import NimbleExtensions
import NimbleViews

// MARK: - View
struct LibraryCellView: View {
	@AppStorage("Feather.libraryCellAppearance") private var _libraryCellAppearance: Int = 0

	var certInfo: Date.ExpirationInfo? {
		Storage.shared.getCertificate(from: app)?.expiration?.expirationInfo()
	}
	
	var app: AppInfoPresentable
	@Binding var selectedInfoAppPresenting: AnyApp?
	@Binding var selectedSigningAppPresenting: AnyApp?
	@Binding var selectedInstallAppPresenting: AnyApp?
	
	// MARK: Body
	var body: some View {
		HStack(spacing: 9) {
			FRAppIconView(app: app, size: 57, cornerRadius: 14)
			
			NBTitleWithSubtitleView(
				title: app.name ?? "Unknown",
				subtitle: _desc,
				linelimit: 0
			)
			
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
	
	private var _desc: String {
		if
			let version = app.version,
			let id = app.identifier
		{
			return "\(version) • \(id)"
		} else {
			return "Unknown"
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
					FRExpirationPillView(
						title: "Install",
						showOverlay: _libraryCellAppearance == 0,
						expiration: certInfo
					)
				}
			} else {
				Button {
					selectedSigningAppPresenting = AnyApp(base: app)
				} label: {
					FRExpirationPillView(
						title: "Sign",
						showOverlay: true,
						expiration: nil
					)
				}
			}
		}
		.buttonStyle(.borderless)
	}
}
