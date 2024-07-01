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
		let randomString = genRandomString()
		let folderUrl = baseFolder
			.appendingPathComponent("Apps")
			.appendingPathComponent("Unsigned")
			.appendingPathComponent(randomString)
				
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
	
	func genRandomString() -> String {
		let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
		return String((0..<16).map{ _ in letters.randomElement()! })
	}
	
	
	func extractFileAndAddToAppsTab(packageURL: String, completion: @escaping (String?, Error?) -> Void) {
		guard let fileURL = URL(string: packageURL) else {
			completion(nil, NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
			return
		}
		
		let destinationURL = fileURL.deletingLastPathComponent()
		do {
			
			
			
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
			print("Saved to: \(destinationUrl.path)")
			
			downloadCompletion?(destinationUrl.path, nil)
			dldelegate?.stopDownload()
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
