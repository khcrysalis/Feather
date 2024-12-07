//
//  SourceAppActions.swift
//  feather
//
//  Created by samara on 7/9/24.
//  Copyright (c) 2024 Samara M (khcrysalis)
//

import Foundation
import UIKit
import Nuke
import AlertKit
extension SourceAppViewController {
	@objc func getButtonTapped(_ sender: UIButton) {
		let indexPath = IndexPath(row: sender.tag, section: 0)
		let app = isFiltering ? filteredApps[indexPath.row] : apps[indexPath.row]
		var downloadURL: URL!
		
		if let appDownloadURL = app.versions?[0].downloadURL {
			downloadURL = appDownloadURL
		} else if let appDownloadURL = app.downloadURL {
			downloadURL = appDownloadURL
		} else {
			return
		}
		
		let appUUID = app.bundleIdentifier
		
		if let task = DownloadTaskManager.shared.task(for: appUUID) {
			switch task.state {
			case .inProgress:
				DownloadTaskManager.shared.cancelDownload(for: appUUID)
			default:
				break
			}
		} else {
			if let downloadURL = downloadURL {
				startDownloadIfNeeded(for: indexPath, in: tableView, downloadURL: downloadURL, appUUID: appUUID, sourceLocation: self.name ?? String.localized("UNKNOWN"))
			}
		}
	}
	
	
	@objc func getButtonHold(_ gesture: UILongPressGestureRecognizer) {
		if gesture.state == .began {
			guard let button = gesture.view as? UIButton else { return }
			let indexPath = IndexPath(row: button.tag, section: 0)
			let app = isFiltering ? filteredApps[indexPath.row] : apps[indexPath.row]
			let alertController = UIAlertController(title: app.name, message: String.localized("SOURCES_CELLS_ACTIONS_HOLD_AVAILABLE_VERSIONS"), preferredStyle: .actionSheet)
			
			if let sortedVersions = app.versions {
				for version in sortedVersions {
					let versionString = version.version
					let downloadURL = version.downloadURL
					
					let action = UIAlertAction(title: versionString, style: .default) { action in
						self.startDownloadIfNeeded(for: indexPath, in: self.tableView, downloadURL: downloadURL, appUUID: app.bundleIdentifier, sourceLocation: self.name ?? String.localized("UNKNOWN"))
						alertController.dismiss(animated: true, completion: nil)
					}
					
					alertController.addAction(action)
				}
			}
			
			alertController.addAction(UIAlertAction(title: String.localized("CANCEL"), style: .cancel, handler: nil))
			
			DispatchQueue.main.async {
                let keyWindow = UIApplication.shared.connectedScenes.compactMap { ($0 as? UIWindowScene)?.keyWindow }.last
                if let viewController = keyWindow?.rootViewController {
					viewController.present(alertController, animated: true, completion: nil)
				}
			}
		}
	}


}
