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
	
	var certInfo: (info: String?, color: Color?) {
		let data = Storage.shared.getCertificate(from: app)?.expiration?.expirationInfo()
		return (data?.formatted, data?.color)
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
					_buttonLabel(
						certInfo.info ?? "Install",
						color: certInfo.color ?? Color(uiColor: .quaternarySystemFill)
					)
				}
			} else {
				Button {
					selectedSigningAppPresenting = AnyApp(base: app)
				} label: {
					_buttonLabel("Sign", isWide: true)
				}
			}
		}
		.buttonStyle(.borderless)
	}
	
	@ViewBuilder
	private func _buttonLabel(
		_ title: String,
		color: Color = Color(uiColor: .quaternarySystemFill),
		isWide: Bool = false
	) -> some View {
		Text(title)
			.font(.headline.bold())
			.foregroundStyle(color != Color(uiColor: .quaternarySystemFill) ? .white : .accentColor)
			.padding(.horizontal, isWide ? 22 : 12)
			.padding(.vertical, 6)
			.background {
				color.opacity(0.85)
			}
			.clipShape(Capsule())
	}

}
