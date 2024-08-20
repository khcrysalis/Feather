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
		let uuid = UUID().uuidString
		let tempDirectory = NSHomeDirectory() + "/tmp/\(uuid)"
		let payloadPath = "\(tempDirectory)/Payload"
		let ipaPath = "\(tempDirectory).ipa"
		
		do {
			UIApplication.shared.isIdleTimerDisabled = true
			try FileManager.default.createDirectory(atPath: tempDirectory, withIntermediateDirectories: true)
			try FileManager.default.copyItem(atPath: filePath, toPath: payloadPath)
			MBProgressHUD.showAdded(to: self.view, animated: true)
			DispatchQueue(label: "compress").async {
				do {
					let payloadURL = URL(fileURLWithPath: payloadPath)
					let ipaURL = URL(fileURLWithPath: ipaPath)
					try FileManager.default.zipItem(at: payloadURL, to: ipaURL)
					DispatchQueue.main.async {
						UIApplication.shared.isIdleTimerDisabled = false
						MBProgressHUD.hide(for: self.view, animated: true)
						runHTTPSServer()
						if Preferences.userSelectedServer {
							
							let bundleid = (meow.value(forKey: "bundleidentifier") as? String ?? "").addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
							let name = (meow.value(forKey: "name") as? String ?? "").addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
							let version = (meow.value(forKey: "version") as? String ?? "").addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
							let fetchurl = "https://localhost.direct:8443/tempsigned.ipa?uuid=\(uuid)".addingPercentEncoding(withAllowedCharacters: .alphanumerics)!

							let urlString = "itms-services://?action=download-manifest&url=" + ("\(Preferences.onlinePath ?? Preferences.defaultInstallPath)/genPlist?bundleid=\(bundleid)&name=\(name)&version=\(version)&fetchurl=\(fetchurl)").addingPercentEncoding(withAllowedCharacters: .alphanumerics)!
							
							if let url = URL(string: urlString) {
								UIApplication.shared.open(url, options: [:], completionHandler: nil)
							}

							self.popupVC.dismiss(animated: true)
						} else {

							UIApplication.shared.open(URL(string: "itms-services://?action=download-manifest&url=\("https://localhost.direct:8443/manifest.plist?bundleid=\(meow.value(forKey: "bundleidentifier") as? String ?? "")&uuid=\(uuid)&name=\((meow.value(forKey: "name") as? String ?? "").addingPercentEncoding(withAllowedCharacters: .alphanumerics)!)".addingPercentEncoding(withAllowedCharacters: .alphanumerics)!)")!, options: [:], completionHandler: nil)
							
							self.popupVC.dismiss(animated: true)
						}


					}
				} catch {
					DispatchQueue.main.async {
						MBProgressHUD.hide(for: self.view, animated: true)
					}
					Debug.shared.log(message: "\(error)", type: .error)
				}
			}
		} catch {
			Debug.shared.log(message: "\(error)", type: .error)
		}
	}
	
	@objc func shareFile(meow: NSManagedObject, filePath: String) {
		
		let uuid = UUID().uuidString
		let tempDirectory = FileManager.default.temporaryDirectory.appendingPathComponent(uuid)
		let payloadPath = tempDirectory.appendingPathComponent("Payload").path
		
		let fileName = (meow.value(forKey: "name") as? String ?? "UnknownApp").trimmingCharacters(in: .whitespacesAndNewlines)
		let sanitizedFileName = fileName.replacingOccurrences(of: "/", with: "_")
		let ipaPath = tempDirectory.appendingPathComponent("\(sanitizedFileName).ipa").path
		
		do {
			UIApplication.shared.isIdleTimerDisabled = true
			try FileManager.default.createDirectory(atPath: tempDirectory.path, withIntermediateDirectories: true)
			try FileManager.default.copyItem(atPath: filePath, toPath: payloadPath)
			
			MBProgressHUD.showAdded(to: self.view, animated: true)
			
			DispatchQueue(label: "compress").async {
				do {
					let payloadURL = URL(fileURLWithPath: payloadPath)
					let ipaURL = URL(fileURLWithPath: ipaPath)
					try FileManager.default.zipItem(at: payloadURL, to: ipaURL)
					
					DispatchQueue.main.async {
						UIApplication.shared.isIdleTimerDisabled = false
						MBProgressHUD.hide(for: self.view, animated: true)
						
						let activityViewController = UIActivityViewController(activityItems: [ipaURL], applicationActivities: nil)
						self.present(activityViewController, animated: true, completion: nil)
					}
				} catch {
					DispatchQueue.main.async {
						UIApplication.shared.isIdleTimerDisabled = false
						MBProgressHUD.hide(for: self.view, animated: true)
					}
					Debug.shared.log(message: "Error compressing file: \(error)", type: .error)
				}
			}
		} catch {
			Debug.shared.log(message: "Error preparing file for sharing: \(error)", type: .error)
		}
	}


	
}
