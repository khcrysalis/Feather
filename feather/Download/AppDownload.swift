//
//  AppDownload.swift
//  feather
//
//  Created by samara on 6/29/24.
//

import Foundation
import ZIPFoundation

class AppDownload: NSObject {
	var dldelegate: DownloadDelegate?
	var destinationUrl: URL?
	var downloadCompletion: ((String?, Error?) -> Void)?
	
	func downloadFile(url: URL, completion: @escaping (String?, Error?) -> Void) {
		let baseFolder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
		let folderUrl = baseFolder
			.appendingPathComponent("Apps")
			.appendingPathComponent("Unsigned")
			.appendingPathComponent(url.deletingPathExtension().lastPathComponent+UUID().uuidString)
				
		do {
			try FileManager.default.createDirectory(at: folderUrl, withIntermediateDirectories: true, attributes: nil)
		} catch {
			print("Error creating directory: \(error)")
			completion(nil, error)
			return
		}

		let destinationUrl = folderUrl.appendingPathComponent(url.lastPathComponent)

		self.destinationUrl = destinationUrl
		self.downloadCompletion = completion

		let sessionConfig = URLSessionConfiguration.default
		let session = URLSession(configuration: sessionConfig, delegate: self, delegateQueue: nil)
		let downloadTask = session.downloadTask(with: url)
		downloadTask.resume()
	}
	
	func extractFileAndAddToAppsTab(packageURL: String, completion: @escaping (String?, Error?) -> Void) {
		let fileURL = URL(fileURLWithPath: packageURL)
		
		let destinationURL = fileURL.deletingLastPathComponent()
		let fileManager = FileManager.default
		
		if !fileManager.fileExists(atPath: fileURL.path) {
			completion(nil, NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "File does not exist"]))
			return
		}
		
		do {
			try fileManager.unzipItem(at: fileURL, to: destinationURL)
			dldelegate?.updateDownloadProgress(progress: 1)
			try fileManager.removeItem(at: fileURL)
			
			let payloadURL = destinationURL.appendingPathComponent("Payload")
			
			let contents = try fileManager.contentsOfDirectory(at: payloadURL, includingPropertiesForKeys: nil, options: [])
			
			if let appDirectory = contents.first(where: { $0.pathExtension == "app" }) {
				let sourceURL = appDirectory
				let targetURL = destinationURL.appendingPathComponent(sourceURL.lastPathComponent)
				try fileManager.moveItem(at: sourceURL, to: targetURL)
				try fileManager.removeItem(at: destinationURL.appendingPathComponent("Payload"))
				completion(targetURL.path, nil)
			} else {
				completion(nil, NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No .app directory found in Payload"]))
			}
			
			dldelegate?.stopDownload()
			completion(nil, nil)
		} catch {
			print("Something went wrong: \(error.localizedDescription)")
			completion(nil, error)
		}

	}

	
}

extension AppDownload: URLSessionDownloadDelegate {
	func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
		guard let destinationUrl = destinationUrl else {
			return
		}
		let fileManager = FileManager.default
		do {
			try fileManager.moveItem(at: location, to: destinationUrl)
//			print("Saved to: \(destinationUrl.path)")
			
			downloadCompletion?(destinationUrl.path, nil)
		} catch {
			print("Failed to save file at: \(destinationUrl.path), \(String(describing: error))")
			downloadCompletion?(destinationUrl.path, error)
		}
	}
	
	func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
		guard let destinationUrl = destinationUrl else {
			return
		}
		if let error = error {
			downloadCompletion?(destinationUrl.path, error)
			print("Failed to download: \(task.originalRequest?.url?.absoluteString ?? "Unknown URL"), \(error.localizedDescription)")
		}
	}
	
	func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
		let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
		dldelegate?.updateDownloadProgress(progress: Double(progress) * 0.75)
	}
}
