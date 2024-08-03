//
//  SourceAppDownload.swift
//  feather
//
//  Created by samara on 7/9/24.
//

import Foundation
import UIKit
import Nuke
import AlertKit

extension SourceAppViewController: DownloadDelegate {
	func stopDownload(uuid: String) {
		DispatchQueue.main.async {
			if let task = DownloadTaskManager.shared.task(for: uuid) {
				task.cell.stopDownload()
				downloadTaskManager.removeTask(uuid: uuid)
			}
		}
	}
	
	func startDownload(uuid: String, indexPath: IndexPath) {
		DispatchQueue.main.async {
			if let task = DownloadTaskManager.shared.task(for: uuid) {
				task.cell.startDownload()
				downloadTaskManager.updateTask(uuid: uuid, state: .inProgress(progress: 0.0))
			}
		}
	}

	
	func updateDownloadProgress(progress: Double, uuid: String) {
		print(progress)
		downloadTaskManager.updateTask(uuid: uuid, state: .inProgress(progress: progress))
	}
}

extension SourceAppViewController {
	func startDownloadIfNeeded(for indexPath: IndexPath, in tableView: UITableView, downloadURL: URL?, appUUID: String?) {
		guard let downloadURL = downloadURL, let appUUID = appUUID, let cell = tableView.cellForRow(at: indexPath) as? SourceAppTableViewCell else {
			return
		}

		if cell.appDownload == nil {
			cell.appDownload = AppDownload()
			cell.appDownload?.dldelegate = self
		}
		DispatchQueue.global(qos: .background).async {
			downloadTaskManager.addTask(uuid: appUUID, cell: cell)
			
			cell.appDownload?.downloadFile(url: downloadURL, appuuid: appUUID) { [weak self] (uuid, filePath, error) in
				guard let self = self else { return }
				if let error = error {
					downloadTaskManager.updateTask(uuid: appUUID, state: .failed(error: error))
					self.errorPopup(error: error.localizedDescription)
				} else if let uuid = uuid, let filePath = filePath {
					cell.appDownload?.extractCompressedBundle(packageURL: filePath) { (targetBundle, error) in
						
						if let error = error {
							downloadTaskManager.updateTask(uuid: appUUID, state: .failed(error: error))
							self.errorPopup(error: error.localizedDescription)
						} else if let targetBundle = targetBundle {
							cell.appDownload?.addToApps(bundlePath: targetBundle, uuid: uuid) { error in
								if let error = error {
									downloadTaskManager.updateTask(uuid: appUUID, state: .failed(error: error))
									self.errorPopup(error: error.localizedDescription)
								} else {
									downloadTaskManager.updateTask(uuid: appUUID, state: .completed)
									self.successPopup()
								}
							}
						}
						
					}
				}
			}
			
			self.startDownload(uuid: appUUID, indexPath: indexPath)
		}
	}

}
// TODO: Make a proper error handler
extension SourceAppViewController {
	func successPopup() {
		DispatchQueue.main.async {
			let alertView = AlertAppleMusic17View(title: "Added to Apps", subtitle: nil, icon: .done)
			if let viewController = UIApplication.shared.windows.first?.rootViewController {
				alertView.present(on: viewController.view)
			}
		}
	}
	
	func errorPopup(error: String) {
		DispatchQueue.main.async {
			let alertView = AlertAppleMusic17View(title: "Error", subtitle: error, icon: .error)
			if let viewController = UIApplication.shared.windows.first?.rootViewController {
				alertView.present(on: viewController.view)
			}
		}
	}
}

protocol DownloadDelegate: AnyObject {
	func updateDownloadProgress(progress: Double, uuid: String)
	func stopDownload(uuid: String)
}
