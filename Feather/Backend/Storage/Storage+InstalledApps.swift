//
//  Storage+InstalledApps.swift
//  Feather
//

import CoreData
import Foundation
import NimbleExtensions

// Independent record of any app that completed a successful installation.
// Holds a live reference to the certificate it was signed with + snapshots
// the certificate's details.
extension Storage {
	func recordSuccessfulInstall(of app: AppInfoPresentable) {
		guard let uuid = app.uuid, let identifier = app.identifier else { return }

		let request: NSFetchRequest<InstalledApp> = InstalledApp.fetchRequest()
		request.predicate = NSPredicate(format: "identifier == %@", identifier)
		request.fetchLimit = 1

		let installed = (try? context.fetch(request))?.first ?? InstalledApp(context: context)

		installed.uuid = uuid
		installed.identifier = identifier
		installed.name = app.name ?? .localized("Unknown")
		installed.version = app.version ?? ""
		installed.wasSigned = app.isSigned
		installed.date = Date()

		_applyCertificateSnapshot(getCertificate(from: app), to: installed)

		installed.sourceRepositoryName = sourceMetadata(for: app)?.sourceRepositoryName

		if
			let bundleURL = getAppDirectory(for: app),
			let icon = iconTest(bundleURL)
		{
			installed.iconData = icon.pngData()
		}

		saveContext()
	}

	func getInstalledApps() -> [InstalledApp] {
		let request: NSFetchRequest<InstalledApp> = InstalledApp.fetchRequest()
		request.sortDescriptors = [NSSortDescriptor(keyPath: \InstalledApp.date, ascending: false)]
		return (try? context.fetch(request)) ?? []
	}

	func deleteInstalledApp(_ app: InstalledApp) {
		context.delete(app)
		saveContext()
	}

	// called after a certificate is (re-)added, in case it's the same certificate
	func relinkInstalledApps(toNewlyAddedCertificate certificate: CertificatePair) {
		guard
			let teamIdentifier = getProvisionFileDecoded(for: certificate)?.TeamIdentifier.first,
			!teamIdentifier.isEmpty
		else { return }

		let request: NSFetchRequest<InstalledApp> = InstalledApp.fetchRequest()
		request.predicate = NSPredicate(
			format: "certificate == nil AND certificateTeamIdentifier == %@",
			teamIdentifier
		)

		guard let orphaned = try? context.fetch(request), !orphaned.isEmpty else { return }

		for installed in orphaned {
			_applyCertificateSnapshot(certificate, to: installed)
		}

		saveContext()
	}

	private func _applyCertificateSnapshot(_ certificate: CertificatePair?, to installed: InstalledApp) {
		installed.certificate = certificate

		guard let certificate else {
			installed.certificateNickname = nil
			installed.certificateName = nil
			installed.certificateAppIDName = nil
			installed.certificateTeamIdentifier = nil
			installed.certificateExpiration = nil
			installed.certificateRevoked = false
			return
		}

		let decoded = getProvisionFileDecoded(for: certificate)
		installed.certificateNickname = certificate.nickname
		installed.certificateName = decoded?.Name
		installed.certificateAppIDName = decoded?.AppIDName
		installed.certificateTeamIdentifier = decoded?.TeamIdentifier.first
		installed.certificateExpiration = certificate.expiration
		installed.certificateRevoked = certificate.revoked
	}
}

extension InstalledApp: AppInfoPresentable {
	var isSigned: Bool { wasSigned }
	var source: URL? { nil }
	var icon: String? { nil }
}

extension InstalledApp {
	var certificateExpirationInfo: Date.ExpirationInfo? {
		certificateExpiration?.expirationInfo()
	}

	var isCertificateExpiredOrRevoked: Bool {
		if certificateRevoked { return true }
		guard let expiration = certificateExpiration else { return false }
		return expiration <= Date()
	}
}
