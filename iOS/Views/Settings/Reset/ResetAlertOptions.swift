//
//  ResetAlertOptions.swift
//  feather
//
//  Created by samara on 22.10.2024.
//

import Foundation
import Nuke

extension SettingsViewController {
	fileprivate func resetAlert(
		title: String,
		message: String,
		actions: [(String, UIAlertAction.Style, () -> Void)] = [],
		completion: (() -> Void)? = nil
	) {
		let alertView = UIAlertController(
			title: title,
			message: message,
			preferredStyle: UIDevice.current.userInterfaceIdiom == .pad ? .alert : .actionSheet
		)
		
		let cancelAction = UIAlertAction(title: String.localized("CANCEL"), style: .cancel, handler: nil)
		alertView.addAction(cancelAction)
		
		for (actionTitle, actionStyle, handler) in actions {
			let alertAction = UIAlertAction(title: actionTitle, style: actionStyle) { _ in
				handler()
				completion?()
			}
			alertView.addAction(alertAction)
		}
		
		present(alertView, animated: true)
	}
	
	fileprivate func cacheSize() -> String {
		var totalCacheSize = URLCache.shared.currentDiskUsage
		if let nukeCache = ImagePipeline.shared.configuration.dataCache as? DataCache {
			totalCacheSize += nukeCache.totalSize
		}
		return "Network Cache size: \(ByteCountFormatter.string(fromByteCount: Int64(totalCacheSize), countStyle: .file))"
	}
	
	fileprivate func sourcesCount() -> String {
		let l = CoreDataManager.shared.getAZSources()
		return "Source Count: \(l.count)"
	}
	
	fileprivate func downloadedCount() -> String {
		let l = CoreDataManager.shared.getDatedDownloadedApps()
		return "Downloaded App Count: \(l.count)"
	}
	
	fileprivate func signedCount() -> String {
		let l = CoreDataManager.shared.getDatedSignedApps()
		return "Signed App Count: \(l.count)"
	}
	
	fileprivate func certificateCount() -> String {
		let l = CoreDataManager.shared.getDatedCertificate()
		return "Certificate Count: \(l.count)"
	}
	
	public func resetOptionsAction() {
		
		var totalCacheSize = URLCache.shared.currentDiskUsage
		if let nukeCache = ImagePipeline.shared.configuration.dataCache as? DataCache {
			totalCacheSize += nukeCache.totalSize
		}
		
		let message = ""
		+ "\(cacheSize())\n"
		+ "\(sourcesCount())\n"
		+ "\(signedCount())\n"
		+ "\(downloadedCount())\n"
		+ "\(certificateCount())"
		
		resetAlert(
			title: "",
			message: message,
			actions: [
				("Reset Network Cache", .default, {
					ResetDataClass.shared.clearNetworkCache()
				}),
				("Reset Sources", .default, {
					ResetDataClass.shared.resetSources(resetAll: false)
				}),
				("Reset Signed Apps", .default, {
					ResetDataClass.shared.deleteSignedApps()
				}),
				("Reset Downloaded Apps", .default, {
					ResetDataClass.shared.deleteDownloadedApps()
				}),
				("Reset Certificates", .default, {
					ResetDataClass.shared.resetCertificates(resetAll: false)
				}),
			]
		) {
			self.alertToFinish()
		}
	}
	
	public func resetAllAction() {
		resetAlert(
			title: "Reset All Settings",
			message: "This action is IRREVERSIBLE. The app will go back to its original state.",
			actions: [
				("Proceed", .destructive, {
					ResetDataClass.shared.resetAll()
				})
			]
		) {
			self.alertToFinish()
		}
	}
	
	public func alertToFinish() {
		let alertController = UIAlertController(
			title: "",
			message: String.localized("SUCCESS_REQUIRES_RESTART"),
			preferredStyle: .alert
		)
		
		let closeAction = UIAlertAction(title: String.localized("OK"), style: .default) { _ in
			CFPreferencesAppSynchronize(kCFPreferencesCurrentApplication)
			UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
			exit(0)
		}
		
		alertController.addAction(closeAction)
		present(alertController, animated: true, completion: nil)
	}
}

