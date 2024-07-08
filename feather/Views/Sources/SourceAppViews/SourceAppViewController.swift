//
//  SourceAppViewController.swift
//  feather
//
//  Created by samara on 5/22/24.
//

import Foundation
import UIKit
import Nuke
import AlertKit

class SourceAppViewController: UITableViewController {

	let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
	
	var apps: [StoreApps] = []
	var name: String? { didSet { self.title = name } }
	
	private var downloadTasks: [String: (cell: SourceAppTableViewCell, progress: CGFloat)] = [:]
	private var appUUIDs: [Int: String] = [:]
	
	init() { super.init(style: .plain) }
	required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupNavigation()
		setupViews()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
	}
	
	fileprivate func setupViews() {
		self.tableView.backgroundColor = UIColor(named: "Background")
		self.tableView.dataSource = self
		self.tableView.delegate = self
		self.tableView.register(SourceAppTableViewCell.self, forCellReuseIdentifier: "CustomCell")
		self.tableView.tableHeaderView = UIView()
	}
	
	fileprivate func setupNavigation() {
		self.navigationItem.largeTitleDisplayMode = .never
	}
}

extension SourceAppViewController {
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return apps.count }
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = SourceAppTableViewCell(style: .subtitle, reuseIdentifier: "RoundedBackgroundCell")
		
		let app = apps[indexPath.row]

		cell.configure(with: app)
		cell.selectionStyle = .none
		cell.getButton.tag = indexPath.row
		cell.getButton.addTarget(self, action: #selector(getButtonTapped(_:)), for: .touchUpInside)
		
		let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(getButtonHold(_:)))
		cell.getButton.addGestureRecognizer(longPressGesture)
		cell.getButton.longPressGestureRecognizer = longPressGesture
		
		if let iconURL = app.value(forKey: "iconURL") as? URL  {
			SectionIcons.loadImageFromURL(from: iconURL, for: cell, at: indexPath, in: tableView)
		} else {
			SectionIcons.sectionImage(to: cell, with: UIImage(named: "unknown")!)
		}
		return cell
	}
	
	override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		if apps.isEmpty {
			return nil
		} else {
			return "\(apps.count) Apps"
		}
	}
}


extension SourceAppViewController: DownloadDelegate {

	func stopDownload(uuid: String) {
		DispatchQueue.main.async {
			if let task = self.downloadTasks[uuid] {
				task.cell.stopDownload()
				self.downloadTasks.removeValue(forKey: uuid)
			}
		}
	}
	
	func startDownload(uuid: String, indexPath: IndexPath) {
		DispatchQueue.main.async {
			if let cell = self.tableView.cellForRow(at: indexPath) as? SourceAppTableViewCell {
				cell.startDownload()
				if let downloadTask = self.downloadTasks[uuid] {
					cell.updateProgress(to: downloadTask.progress)
				}
			}
		}
	}

	
	
	func updateDownloadProgress(progress: Double, uuid: String) {
		DispatchQueue.main.async {
			if var downloadTask = self.downloadTasks[uuid] {
				downloadTask.progress = CGFloat(progress)
				downloadTask.cell.updateProgress(to: downloadTask.progress)
				self.downloadTasks[uuid] = downloadTask
			}
		}
	}
	
	@objc func getButtonTapped(_ sender: UIButton) {
		let indexPath = IndexPath(row: sender.tag, section: 0)
		let app = apps[indexPath.row]
		var downloadURL: URL!
		
		if let firstApp = app.versions?.firstObject as? StoreVersions,
				  let firstAppIconURL = firstApp.downloadURL {
			downloadURL = firstAppIconURL
		} else if (app.downloadURL != nil) {
			downloadURL = app.downloadURL
		} else {
			return
		}
		
		
		if let downloadURL = downloadURL {
			startDownloadIfNeeded(for: indexPath, in: tableView, downloadURL: downloadURL)
		}
	}
	
	@objc func getButtonHold(_ gesture: UILongPressGestureRecognizer) {
		if gesture.state == .began {
			guard let button = gesture.view as? UIButton else { return }
			let indexPath = IndexPath(row: button.tag, section: 0)
			let app = apps[indexPath.row]
			let alertController = UIAlertController(title: app.name, message: "Available Versions", preferredStyle: .actionSheet)
			
			if let versions = app.versions {
				for version in versions {
					guard let versionString = (version as AnyObject).value(forKey: "version") as? String else {
						return
					}
					
					guard let downloadURL = (version as AnyObject).value(forKey: "downloadURL") as? URL else {
						return
					}
					
					let action = UIAlertAction(title: versionString, style: .default) { action in
						self.startDownloadIfNeeded(for: indexPath, in: self.tableView, downloadURL: downloadURL)
						alertController.dismiss(animated: true, completion: nil)
					}
					
					alertController.addAction(action)
				}
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

extension SourceAppViewController {
	func startDownloadIfNeeded(for indexPath: IndexPath, in tableView: UITableView, downloadURL: URL?) {
		guard let downloadURL = downloadURL, let cell = tableView.cellForRow(at: indexPath) as? SourceAppTableViewCell else {
			return
		}

		if let uuid = appUUIDs[indexPath.row], let existingTask = downloadTasks[uuid] {
			print("Canceling existing download for indexPath: \(indexPath)")
			existingTask.cell.stopDownload()
			downloadTasks.removeValue(forKey: uuid)
			existingTask.cell.appDownload?.cancelDownload()
			appUUIDs[indexPath.row] = nil
		}

		if cell.appDownload == nil {
			cell.appDownload = AppDownload()
			cell.appDownload?.dldelegate = self
		}

		// Start new download
		cell.appDownload?.downloadFile(url: downloadURL) { [weak self] (uuid, filePath, error) in
			guard let self = self else { return }
			DispatchQueue.main.async {
				if let error = error {
					self.errorPopup(error: error.localizedDescription)
				} else if let uuid = uuid, let filePath = filePath {
					self.downloadTasks[uuid]?.cell.stopDownload()
					self.downloadTasks.removeValue(forKey: uuid)
					self.appUUIDs[indexPath.row] = nil
					cell.appDownload?.extractCompressedBundle(packageURL: filePath) { (targetBundle, error) in
						if let error = error {
							self.errorPopup(error: error.localizedDescription)
						} else if let targetBundle = targetBundle {
							cell.appDownload?.addToApps(bundlePath: targetBundle, uuid: uuid) { error in
								if let error = error {
									self.errorPopup(error: error.localizedDescription)
								} else {
									self.successPopup()
								}
							}
						}
					}
				}
			}
		}

		if let uuid = cell.appDownload?.currentUUID {
			self.downloadTasks[uuid] = (cell: cell, progress: 0.0)
			self.startDownload(uuid: uuid, indexPath: indexPath)
		}
	}

}

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
