//
//  InstalledAppCellView.swift
//  Feather
//

import SwiftUI
import NimbleExtensions
import NimbleViews

// MARK: - View
// Reflects Feather's own record of a successful install.
struct InstalledAppCellView: View {
	var app: InstalledApp

	var body: some View {
		// when the certificate still exists, observe it directly so a revocation flip
		// (or any other change) redraws this row immediately, same as the Certificates list does
		if let cert = app.certificate {
			_ReactiveContent(app: app, cert: cert)
		} else {
			_StaticContent(app: app)
		}
	}
}

private struct _ReactiveContent: View {
	var app: InstalledApp
	@ObservedObject var cert: CertificatePair

	var body: some View {
		_InstalledAppRow(
			app: app,
			certNickname: cert.nickname,
			certName: app.certificateName,
			certExpiration: cert.expiration,
			certRevoked: cert.revoked
		)
	}
}

private struct _StaticContent: View {
	var app: InstalledApp

	var body: some View {
		_InstalledAppRow(
			app: app,
			certNickname: app.certificateNickname,
			certName: app.certificateName,
			certExpiration: app.certificateExpiration,
			certRevoked: app.certificateRevoked
		)
	}
}

private struct _InstalledAppRow: View {
	@Environment(\.horizontalSizeClass) private var horizontalSizeClass
	@State private var _isInfoPresenting = false

	var app: InstalledApp
	var certNickname: String?
	var certName: String?
	var certExpiration: Date?
	var certRevoked: Bool

	private var _expirationInfo: Date.ExpirationInfo? {
		certExpiration?.expirationInfo()
	}

	private var _isExpiredOrRevoked: Bool {
		if certRevoked { return true }
		guard let certExpiration else { return false }
		return certExpiration <= Date()
	}

	private var _baseDesc: String {
		var parts = ["\(app.version ?? "") • \(app.identifier ?? "")"]

		if let displayName = certNickname ?? certName, !displayName.isEmpty {
			parts.append(displayName)
		}
		if let repositoryName = app.sourceRepositoryName, !repositoryName.isEmpty {
			parts.append(repositoryName)
		}

		return parts.joined(separator: " • ")
	}

	private var _subtitle: Text {
		let base = Text(_baseDesc).foregroundColor(.secondary)
		guard let expirationInfo = _expirationInfo else { return base }
		let expirationText = _isExpiredOrRevoked ? .localized("Expired") : expirationInfo.formatted
		return base
			+ Text(" • ").foregroundColor(.secondary)
			+ Text(expirationText).foregroundColor(_isExpiredOrRevoked ? .red : .blue)
	}

	private var _pillText: String {
		if _isExpiredOrRevoked { return .localized("Expired") }
		return _expirationInfo?.formatted ?? .localized("Open")
	}

	private var _pillColor: Color {
		_isExpiredOrRevoked ? .red : .blue
	}

	var body: some View {
		let isRegular = horizontalSizeClass != .compact

		HStack(spacing: 18) {
			_icon()

			VStack(alignment: .leading, spacing: 2) {
				Text(app.name ?? .localized("Unknown"))
					.font(.headline)
					.foregroundColor(.primary)
				_subtitle
					.font(.subheadline)
			}
			.lineLimit(0)
			.frame(maxWidth: .infinity, alignment: .leading)

			Button {
				UIApplication.openApp(with: app.identifier ?? "")
			} label: {
				Text(_pillText)
					.lineLimit(0)
					.font(.headline.bold())
					.foregroundStyle(.white)
					.padding(.horizontal, 12)
					.padding(.vertical, 6)
					.background(_pillColor)
					.clipShape(Capsule())
			}
			.buttonStyle(.borderless)
		}
		.padding(isRegular ? 12 : 0)
		.background(
			isRegular
				? RoundedRectangle(cornerRadius: 18, style: .continuous)
					.fill(Color(.quaternarySystemFill))
				: nil
		)
		.contentShape(Rectangle())
		.swipeActions {
			Button(.localized("Delete"), systemImage: "trash", role: .destructive) {
				Storage.shared.deleteInstalledApp(app)
			}
		}
		.contextMenu {
			Button(.localized("Get Info"), systemImage: "info.circle") {
				_isInfoPresenting = true
			}
			Divider()
			Button(.localized("Delete"), systemImage: "trash", role: .destructive) {
				Storage.shared.deleteInstalledApp(app)
			}
		}
		.sheet(isPresented: $_isInfoPresenting) {
			InstalledAppInfoView(app: app)
		}
	}

	@ViewBuilder
	private func _icon() -> some View {
		if let iconData = app.iconData, let uiImage = UIImage(data: iconData) {
			Image(uiImage: uiImage).appIconStyle(size: 57)
		} else {
			FRAppIconView(app: app, size: 57)
		}
	}
}
