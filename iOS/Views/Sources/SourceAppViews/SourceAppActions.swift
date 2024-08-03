//
//  SourceAppActions.swift
//  feather
//
//  Created by samara on 7/9/24.
//

import Foundation
import UIKit
import Nuke
import AlertKit
extension SourceAppViewController {
	@objc func getButtonTapped(_ sender: UIButton) {
		let indexPath = IndexPath(row: sender.tag, section: 0)
		let app = apps[indexPath.row]
		var downloadURL: URL!

		let sortedVersions = CoreDataManager.shared.getAZStoreAppVersions(for: app)
		if let firstVersion = sortedVersions.first,
		   let firstAppIconURL = firstVersion.downloadURL {
			downloadURL = firstAppIconURL
		} else if let appDownloadURL = app.downloadURL {
			downloadURL = appDownloadURL
		} else {
			return
		}
		
		let appUUID = app.uuid
		
		if let task = DownloadTaskManager.shared.task(for: appUUID!) {
			switch task.state {
			case .inProgress:
				DownloadTaskManager.shared.cancelDownload(for: appUUID!)
			default:
				break
			}
		} else {
			if let downloadURL = downloadURL {
				startDownloadIfNeeded(for: indexPath, in: tableView, downloadURL: downloadURL, appUUID: appUUID)
			}
		}
	}

	
	@objc func getButtonHold(_ gesture: UILongPressGestureRecognizer) {
		if gesture.state == .began {
			guard let button = gesture.view as? UIButton else { return }
			let indexPath = IndexPath(row: button.tag, section: 0)
			let app = apps[indexPath.row]
			let alertController = UIAlertController(title: app.name, message: "Available Versions", preferredStyle: .actionSheet)
			
			let sortedVersions = CoreDataManager.shared.getAZStoreAppVersions(for: app)
			for version in sortedVersions {
				guard let versionString = version.version else {
					continue
				}
				
				guard let downloadURL = version.downloadURL else {
					continue
				}
				
				let action = UIAlertAction(title: versionString, style: .default) { action in
					self.startDownloadIfNeeded(for: indexPath, in: self.tableView, downloadURL: downloadURL, appUUID: app.uuid)
					alertController.dismiss(animated: true, completion: nil)
				}
				
				alertController.addAction(action)
			}
			
			alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
			
			DispatchQueue.main.async {
				if let viewController = UIApplication.shared.windows.first?.rootViewController {
					viewController.present(alertController, animated: true, completion: nil)
				}
			}
		}
	}
}
