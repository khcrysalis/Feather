//
//  DownloadedAppsViewController+Import.swift
//  feather
//
//  Created by samara on 8/10/24.
//

import Foundation
import UIKit
import UniformTypeIdentifiers
import MBProgressHUD
import CoreData
import SwiftUI

extension LibraryViewController: UIDocumentPickerDelegate {
	func beginImportFile() {
		self.presentDocumentPicker(fileExtension: [
			UTType(filenameExtension: "ipa")!,
			UTType(filenameExtension: "tipa")!
		])
	}
	
	func presentDocumentPicker(fileExtension: [UTType]) {
		let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: fileExtension, asCopy: true)
		documentPicker.delegate = self
		documentPicker.allowsMultipleSelection = false
		present(documentPicker, animated: true, completion: nil)
	}
	
	func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
		guard let selectedFileURL = urls.first else { return }
		let dl = AppDownload()
		let uuid = UUID().uuidString
		MBProgressHUD.showAdded(to: self.view, animated: true)
		dl.importFile(url: selectedFileURL, uuid: uuid) {newUrl, error in
			if let error = error {
				MBProgressHUD.hide(for: self.view, animated: true)
				Debug.shared.log(message: error.localizedDescription, type: .error)
			} else if let newUrl = newUrl {
				dl.extractCompressedBundle(packageURL: newUrl.path) { (targetBundle, error) in
					if let error = error {
						MBProgressHUD.hide(for: self.view, animated: true)
						Debug.shared.log(message: error.localizedDescription, type: .error)
					} else if let targetBundle = targetBundle {
						dl.addToApps(bundlePath: targetBundle, uuid: uuid, sourceLocation: "Imported") { error in
							if let error = error {
								MBProgressHUD.hide(for: self.view, animated: true)
								Debug.shared.log(message: error.localizedDescription, type: .error)
							} else {
								MBProgressHUD.hide(for: self.view, animated: true)
								Debug.shared.log(message: "Done!", type: .success)
								self.tableView.reloadData()
							}
						}
					}
				}
			}
		}
	}
	
	
	func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
		controller.dismiss(animated: true, completion: nil)
	}
}

extension LibraryViewController {
	@objc func startInstallProcess(meow: NSManagedObject, filePath: String) {
		UIApplication.shared.isIdleTimerDisabled = true
		
		let name = (meow.value(forKey: "name") as? String) ?? "UnknownApp"
		let id = (meow.value(forKey: "bundleidentifier") as? String) ?? "stupidfucking.shit"
		let version = (meow.value(forKey: "version") as? String) ?? "1.0"
		
		self.presentTransferPreview(with: filePath, id: id, version: version, name: name)
	}
	
	@objc func shareFile(meow: NSManagedObject, filePath: String) {
		UIApplication.shared.isIdleTimerDisabled = true
		
		let name = (meow.value(forKey: "name") as? String) ?? "UnknownApp"
		let id = (meow.value(forKey: "bundleidentifier") as? String) ?? "stupidfucking.shit"
		let version = (meow.value(forKey: "version") as? String) ?? "1.0"
		
		self.presentTransferPreview(with: filePath, isSharing: true, id: id, version: version, name: name)
	}
	
	func presentTransferPreview(with appPath: String, isSharing: Bool? = false, id: String, version: String, name: String) {
		do {
			self.installer = try Installer(
				path: nil,
				metadata: AppData(id: id, version: Int(version) ?? Int(1.0), name: name)
			)
			
			let transferPreview = TransferPreview(installer: self.installer!, appPath: appPath, appName: name, isSharing: isSharing ?? false)
				.onDisappear {
					self.installer?.shutdownServer()
					self.installer = nil
					UIApplication.shared.isIdleTimerDisabled = true
				}
			
			let hostingController = UIHostingController(rootView: transferPreview)
			hostingController.modalPresentationStyle = .pageSheet
			
			if let presentationController = hostingController.presentationController as? UISheetPresentationController {
				let detent2: UISheetPresentationController.Detent = ._detent(withIdentifier: "Test2", constant: 200.0)
				presentationController.detents = [detent2]
				presentationController.prefersGrabberVisible = true
			}
			
			self.present(hostingController, animated: true)
			
		} catch {
			self.installer?.shutdownServer()
			self.installer = nil
		}
	}
	
}
