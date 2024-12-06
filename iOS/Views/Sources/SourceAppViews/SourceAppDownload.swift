//
//  SourceAppDownload.swift
//  feather
//
//  Created by samara on 7/9/24.
//  Copyright (c) 2024 Samara M (khcrysalis)
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
		downloadTaskManager.updateTask(uuid: uuid, state: .inProgress(progress: progress))
	}
}

extension SourceAppViewController {
	func startDownloadIfNeeded(for indexPath: IndexPath, in tableView: UITableView, downloadURL: URL?, appUUID: String?, sourceLocation: String) {
		guard let downloadURL = downloadURL, let appUUID = appUUID, let cell = tableView.cellForRow(at: indexPath) as? AppTableViewCell else {
			return
		}

		if cell.appDownload == nil {
			cell.appDownload = AppDownload()
			cell.appDownload?.dldelegate = self
		}
		DispatchQueue(label: "DL").async {
			downloadTaskManager.addTask(uuid: appUUID, cell: cell, dl: cell.appDownload!)
			
			cell.appDownload?.downloadFile(url: downloadURL, appuuid: appUUID) { [weak self] (uuid, filePath, error) in
                guard self != nil else { return }
				if let error = error {
					downloadTaskManager.updateTask(uuid: appUUID, state: .failed(error: error))
					Debug.shared.log(message: error.localizedDescription, type: .error)
				} else if let uuid = uuid, let filePath = filePath {
					cell.appDownload?.extractCompressedBundle(packageURL: filePath) { (targetBundle, error) in
						
						if let error = error {
							downloadTaskManager.updateTask(uuid: appUUID, state: .failed(error: error))
							Debug.shared.log(message: error.localizedDescription, type: .error)
						} else if let targetBundle = targetBundle {
							cell.appDownload?.addToApps(bundlePath: targetBundle, uuid: uuid, sourceLocation: sourceLocation) { error in
								if let error = error {
									downloadTaskManager.updateTask(uuid: appUUID, state: .failed(error: error))
									Debug.shared.log(message: error.localizedDescription, type: .error)
								} else {
									downloadTaskManager.updateTask(uuid: appUUID, state: .completed)
									Debug.shared.log(message: String.localized("DONE"), type: .success)
									
									// Check if immediate install is enabled
									if UserDefaults.standard.signingOptions.immediatelyInstallFromSource {
										DispatchQueue.main.async {
											let downloadedApps = CoreDataManager.shared.getDatedDownloadedApps()
											if let downloadedApp = downloadedApps.first(where: { $0.uuid == uuid }) {
												NotificationCenter.default.post(
													name: Notification.Name("InstallDownloadedApp"),
													object: nil,
													userInfo: ["downloadedApp": downloadedApp]
												)
											}
										}
									}
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

protocol DownloadDelegate: AnyObject {
	func updateDownloadProgress(progress: Double, uuid: String)
	func stopDownload(uuid: String)
}

extension UIViewController {
	func topMostViewController() -> UIViewController {
		if let presented = presentedViewController {
			return presented.topMostViewController()
		}
		if let navigation = self as? UINavigationController {
			return navigation.visibleViewController?.topMostViewController() ?? navigation
		}
		if let tab = self as? UITabBarController {
			return tab.selectedViewController?.topMostViewController() ?? tab
		}
		return self
	}
}
