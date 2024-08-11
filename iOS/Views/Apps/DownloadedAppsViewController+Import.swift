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

extension DownloadedAppsViewController: UIDocumentPickerDelegate {
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
						dl.addToApps(bundlePath: targetBundle, uuid: uuid) { error in
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
