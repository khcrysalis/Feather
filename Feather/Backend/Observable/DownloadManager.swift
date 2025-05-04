//
//  enum.swift
//  Feather
//
//  Created by samara on 3.05.2025.
//

import Foundation
import Combine
import UIKit.UIImpactFeedbackGenerator

class Download: Identifiable {
	@Published var progress: Double = 0
	@Published var bytesDownloaded: Int64 = 0
	@Published var totalBytes: Int64 = 0
	
    var task: URLSessionDownloadTask?
    var resumeData: Data?
	
	let id: String
	let url: URL
	let fileName: String
    
    init(
		id: String,
		url: URL
	) {
		self.id = id
        self.url = url
        self.fileName = url.lastPathComponent
    }
}

class DownloadManager: NSObject, ObservableObject {
	static let shared = DownloadManager()
	
    @Published var downloads: [Download] = []
    private var session: URLSession!
    
    override init() {
        super.init()
        let configuration = URLSessionConfiguration.default
        session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }
    
    func startDownload(
		from url: URL,
		id: String = UUID().uuidString
	) -> Download {
        if let existingDownload = downloads.first(where: { $0.url == url }) {
            resumeDownload(existingDownload)
            return existingDownload
        }
        
		let download = Download(id: id, url: url)
        
        let task = session.downloadTask(with: url)
        download.task = task
        task.resume()
        
        downloads.append(download)
        return download
    }
    
    func resumeDownload(_ download: Download) {
        if let resumeData = download.resumeData {
            let task = session.downloadTask(withResumeData: resumeData)
            download.task = task
            task.resume()
        } else if let url = download.task?.originalRequest?.url {
            let task = session.downloadTask(with: url)
            download.task = task
            task.resume()
        }
    }
    
    func cancelDownload(_ download: Download) {
        download.task?.cancel()
        
        if let index = downloads.firstIndex(where: { $0.id == download.id }) {
            downloads.remove(at: index)
        }
    }
    
    func getAllDownloads() -> [Download] {
        return downloads
    }
	
	func getDownload(by id: String) -> Download? {
		return downloads.first(where: { $0.id == id })
	}
}

extension DownloadManager: URLSessionDownloadDelegate {
	func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
		guard let download = downloads.first(where: { $0.task == downloadTask }) else { return }
		
		let tempDirectory = FileManager.default.temporaryDirectory
		let customTempDir = tempDirectory.appendingPathComponent("FeatherDownloads", isDirectory: true)
		
		do {
			try FileManager.default.createDirectory(
				at: customTempDir,
				withIntermediateDirectories: true,
				attributes: nil
			)
			
			let destinationURL = customTempDir.appendingPathComponent(download.fileName)
			
			if FileManager.default.fileExists(atPath: destinationURL.path) {
				try FileManager.default.removeItem(at: destinationURL)
			}
			
			try FileManager.default.moveItem(at: location, to: destinationURL)
			
			FR.handlePackageFile(destinationURL) { err in
				if (err != nil) {
					let generator = UINotificationFeedbackGenerator()
					generator.notificationOccurred(.error)
				}
				
				DispatchQueue.main.async {
					if let index = self.downloads.firstIndex(where: { $0.id == download.id }) {
						self.downloads.remove(at: index)
					}
				}
			}
		} catch {
			print("Error handling downloaded file: \(error.localizedDescription)")
		}
	}
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        guard let download = downloads.first(where: { $0.task == downloadTask }) else { return }
        
        DispatchQueue.main.async {
            download.progress = totalBytesExpectedToWrite > 0 ? Double(totalBytesWritten) / Double(totalBytesExpectedToWrite) : 0
            download.bytesDownloaded = totalBytesWritten
            download.totalBytes = totalBytesExpectedToWrite
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard
			let downloadTask = task as? URLSessionDownloadTask,
        	let download = downloads.first(where: { $0.task == downloadTask })
		else {
			return
		}
		
		DispatchQueue.main.async {
			if let index = self.downloads.firstIndex(where: { $0.id == download.id }) {
				self.downloads.remove(at: index)
			}
		}
    }
}
