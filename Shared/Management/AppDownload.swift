//
//  AppDownload.swift
//  feather
//
//  Created by samara on 6/29/24.
//  Copyright (c) 2024 Samara M (khcrysalis)
//

import Foundation
import ZIPFoundation
import UIKit
import CoreData

class AppDownload: NSObject {
	let progress = Progress(totalUnitCount: 100)
	var dldelegate: DownloadDelegate?
	var downloads = [URLSessionDownloadTask: (uuid: String, appuuid: String, destinationUrl: URL, completion: (String?, String?, Error?) -> Void)]()
	var DirectoryUUID: String?
	var AppUUID: String?
	private var downloadTask: URLSessionDownloadTask?
	private var session: URLSession?

	func downloadFile(url: URL, appuuid: String, completion: @escaping (String?, String?, Error?) -> Void) {
		let uuid = UUID().uuidString
		self.DirectoryUUID = uuid
		self.AppUUID = appuuid
		guard let folderUrl = createUuidDirectory(uuid: uuid) else {
			completion(nil, nil, NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to create directory"]))
			return
		}

		let destinationUrl = folderUrl.appendingPathComponent(url.lastPathComponent)
		let sessionConfig = URLSessionConfiguration.default
		session = URLSession(configuration: sessionConfig, delegate: self, delegateQueue: nil)
		downloadTask = session?.downloadTask(with: url)

		downloads[downloadTask!] = (uuid: uuid, appuuid: appuuid, destinationUrl: destinationUrl, completion: completion)
		downloadTask!.resume()
	}
	
	func importFile(url: URL, uuid: String, completion: @escaping (URL?, Error?) -> Void) {
		guard let folderUrl = createUuidDirectory(uuid: uuid) else {
			completion(nil, NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to create directory"]))
			return
		}
		
		let fileName = url.lastPathComponent
		let destinationUrl = folderUrl.appendingPathComponent(fileName)
		
		do {
			let fileManager = FileManager.default
			try fileManager.moveItem(at: url, to: destinationUrl)
			completion(destinationUrl, nil)
		} catch {
			completion(nil, error)
		}
	}


	func cancelDownload() {
		Debug.shared.log(message: "AppDownload.cancelDownload: User cancelled the download", type: .info)
		downloadTask?.cancel()
		session?.invalidateAndCancel()
		downloadTask = nil
		session = nil
		progress.cancel()
	}

	func createUuidDirectory(uuid: String) -> URL? {
		let baseFolder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
		let folderUrl = baseFolder.appendingPathComponent("Apps/Unsigned").appendingPathComponent(uuid)

		do {
			try FileManager.default.createDirectory(at: folderUrl, withIntermediateDirectories: true, attributes: nil)
			return folderUrl
		} catch {
			return nil
		}
	}
	
	func extractCompressedBundle(packageURL: String, completion: @escaping (String?, Error?) -> Void) {
		let fileURL = URL(fileURLWithPath: packageURL)
		let destinationURL = fileURL.deletingLastPathComponent()
		let fileManager = FileManager.default
		
		guard fileManager.fileExists(atPath: fileURL.path) else {
			completion(nil, NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "File does not exist"]))
			return
		}
		
		DispatchQueue.global(qos: .userInitiated).async {
			let progress = Progress(totalUnitCount: 100)
			let startTime = Date()
			
			do {
				try fileManager.unzipItem(at: fileURL, to: destinationURL, progress: progress)

				guard !progress.isCancelled else {
					try? fileManager.removeItem(at: destinationURL)
					self.cancelDownload()
					DispatchQueue.main.async {
						completion(nil, NSError(domain: "", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unzip operation was cancelled"]))
					}
					return
				}
				
				try fileManager.removeItem(at: fileURL)
				
				let payloadURL = destinationURL.appendingPathComponent("Payload")
				let contents = try fileManager.contentsOfDirectory(at: payloadURL, includingPropertiesForKeys: nil, options: [])
				
				guard let appDirectory = contents.first(where: { $0.pathExtension == "app" }) else {
					DispatchQueue.main.async {
						completion(nil, NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No .app directory found in Payload"]))
					}
					return
				}
				
				let targetURL = destinationURL.appendingPathComponent(appDirectory.lastPathComponent)
				try fileManager.moveItem(at: appDirectory, to: targetURL)
				try fileManager.removeItem(at: payloadURL)
				
				let codeSignatureDirectory = targetURL.appendingPathComponent("_CodeSignature")
				if fileManager.fileExists(atPath: codeSignatureDirectory.path) {
					try fileManager.removeItem(at: codeSignatureDirectory)
					Debug.shared.log(message: "Removed _CodeSignature directory")
				}
				
				DispatchQueue.main.async {
					completion(targetURL.path, nil)
				}
				
			} catch {
				Debug.shared.log(message: "\(error)")
				try? fileManager.removeItem(at: destinationURL)
				self.cancelDownload()
				DispatchQueue.main.async {
					completion(nil, error)
				}
			}
		}
	}

	func addToApps(bundlePath: String, uuid: String, sourceLocation: String? = nil, completion: @escaping (Error?) -> Void) {
		guard let bundle = Bundle(path: bundlePath) else {
			let error = NSError(domain: "Feather", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to load bundle at \(bundlePath)"])
			completion(error)
			return
		}

		if let infoDict = bundle.infoDictionary {

			var iconURL = ""
			if let iconsDict = infoDict["CFBundleIcons"] as? [String: Any],
			   let primaryIconsDict = iconsDict["CFBundlePrimaryIcon"] as? [String: Any],
			   let iconFiles = primaryIconsDict["CFBundleIconFiles"] as? [String],
			   let iconFileName = iconFiles.first,
			   let iconPath = bundle.path(forResource: iconFileName + "@2x", ofType: "png") {
				iconURL = "\(URL(string: iconPath)?.lastPathComponent ?? "")"
			}
			else if let iconFiles = infoDict["CFBundleIconFiles"] as? [String],
			        let iconFileName = iconFiles.first {
			    iconURL = iconFileName
			}

			CoreDataManager.shared.addToDownloadedApps(
				version: (infoDict["CFBundleShortVersionString"] as? String)!,
				name: (infoDict["CFBundleDisplayName"] as? String ?? infoDict["CFBundleName"] as? String)!,
				bundleidentifier: (infoDict["CFBundleIdentifier"] as? String)!,
				iconURL: iconURL,
				uuid: uuid,
				appPath: "\(URL(string: bundlePath)?.lastPathComponent ?? "")", 
				sourceLocation: sourceLocation) {_ in
			}

			completion(nil)
		} else {
			let error = NSError(domain: "Feather", code: 3, userInfo: [NSLocalizedDescriptionKey: "Info.plist not found in bundle at \(bundlePath)"])
			completion(error)
		}
	}
}

extension AppDownload: URLSessionDownloadDelegate {
	func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
		guard let download = downloads[downloadTask] else {
			return
		}
		let fileManager = FileManager.default
		do {
			try fileManager.moveItem(at: location, to: download.destinationUrl)
			download.completion(download.uuid, download.destinationUrl.path, nil)
		} catch {
			download.completion(download.uuid, download.destinationUrl.path, error)
		}
		downloads.removeValue(forKey: downloadTask)
	}

	func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
		guard let download = downloads[task as! URLSessionDownloadTask] else {
			return
		}
		if let error = error {
			download.completion(download.uuid, download.destinationUrl.path, error)
		}
		downloads.removeValue(forKey: task as! URLSessionDownloadTask)
	}

	func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
		let progress = CGFloat(totalBytesWritten) / CGFloat(totalBytesExpectedToWrite)
		if let uuid = downloads[downloadTask]?.appuuid {
			dldelegate?.updateDownloadProgress(progress: progress, uuid: uuid)
		}
	}
}
enum HandleIPAFileError: Error {
	case importFailed(String)
	case extractionFailed(String)
	case additionFailed(String)
}

func handleIPAFile(destinationURL: URL, uuid: String, dl: AppDownload) throws {
	let semaphore = DispatchSemaphore(value: 0)
	
	var functionError: Error? = nil
	var newUrl: URL? = nil
	var targetBundle: String? = nil
	
	DispatchQueue(label: "DL").async {
		dl.importFile(url: destinationURL, uuid: uuid) { resultUrl, error in
			if let error = error {
				functionError = HandleIPAFileError.importFailed(error.localizedDescription)
				semaphore.signal()
				return
			}
			
			newUrl = resultUrl
			
			guard let validNewUrl = newUrl else {
				functionError = HandleIPAFileError.importFailed("No URL returned from import.")
				semaphore.signal()
				return
			}
			
			dl.extractCompressedBundle(packageURL: validNewUrl.path) { bundle, error in
				if let error = error {
					functionError = HandleIPAFileError.extractionFailed(error.localizedDescription)
					semaphore.signal()
					return
				}
				
				targetBundle = bundle
				
				guard let validTargetBundle = targetBundle else {
					functionError = HandleIPAFileError.extractionFailed("No bundle returned from extraction.")
					semaphore.signal()
					return
				}
				
				dl.addToApps(bundlePath: validTargetBundle, uuid: uuid, sourceLocation: "Imported") { error in
					if let error = error {
						functionError = HandleIPAFileError.additionFailed(error.localizedDescription)
					}
					
					semaphore.signal()
				}
			}
		}
	}
	
	semaphore.wait()
	
	if let error = functionError {
		DispatchQueue.main.async {
			Debug.shared.log(message: error.localizedDescription, type: .error)
		}
		throw error
	} else {
		DispatchQueue.main.async {
			Debug.shared.log(message: "Done!", type: .success)
			NotificationCenter.default.post(name: Notification.Name("lfetch"), object: nil)
		}
	}
}
