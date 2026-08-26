//
//  InstalledAppInfoView.swift
//  Feather
//

import SwiftUI
import NimbleExtensions
import NimbleViews

// MARK: - View
// Deliberately reads only the InstalledApp record so it still works after
// the Signed/Imported entry that produced it has been deleted.
struct InstalledAppInfoView: View {
	var app: InstalledApp

	// MARK: Body
	var body: some View {
		NBNavigationView(app.name ?? .localized("Unknown"), displayMode: .inline) {
			List {
				Section {} header: {
					_icon()
						.frame(maxWidth: .infinity, alignment: .center)
				}

				NBSection(.localized("Info")) {
					if let name = app.name {
						_infoCell(.localized("Name"), desc: name)
					}
					if let version = app.version {
						_infoCell(.localized("Version"), desc: version)
					}
					if let identifier = app.identifier {
						_infoCell(.localized("Identifier"), desc: identifier)
					}
					if let date = app.date {
						_infoCell(.localized("Date Installed"), desc: date.formatted())
					}
				}

				if let cert = app.certificate {
					// live certificate still exists: show the exact same cell Signed's info view does
					NBSection(.localized("Certificate")) {
						CertificatesCellView(cert: cert)
					}
				} else if app.certificateNickname != nil || app.certificateName != nil || app.certificateAppIDName != nil {
					// certificate has been deleted: fall back to what we snapshotted
					NBSection(.localized("Certificate")) {
						NBTitleWithSubtitleView(
							title: app.certificateNickname ?? app.certificateName ?? .localized("Unknown"),
							subtitle: app.certificateAppIDName ?? .localized("Unknown")
						)
						if let expirationInfo = app.certificateExpirationInfo {
							LabeledContent(.localized("Expires")) {
								Text(app.isCertificateExpiredOrRevoked ? .localized("Expired") : expirationInfo.formatted)
									.foregroundStyle(app.isCertificateExpiredOrRevoked ? .red : .blue)
							}
						}
					}
				}
			}
			.toolbar {
				NBToolbarButton(role: .close)
			}
		}
	}

	@ViewBuilder
	private func _icon() -> some View {
		if let iconData = app.iconData, let uiImage = UIImage(data: iconData) {
			Image(uiImage: uiImage).appIconStyle()
		} else {
			FRAppIconView(app: app)
		}
	}

	@ViewBuilder
	private func _infoCell(_ title: String, desc: String) -> some View {
		LabeledContent(title) {
			Text(desc)
		}
		.copyableText(desc)
	}
}
