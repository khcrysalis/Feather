//
//  BackgroundTaskManager.swift
//  Feather
//
//  Created by Nagata Asami on 4/1/26.
//

import Foundation
import BackgroundTasks
import CryptoKit

@available(iOS 26.0, *)
class BackgroundTaskManager: ObservableObject {
    static let shared = BackgroundTaskManager()
    
    private let baseId = "\(Bundle.main.bundleIdentifier!).userTask"
    
    private var activeTasks: [String: BGContinuedProcessingTask] = [:]
    private var registeredTasks: Set<String> = []
    
    func startTask(for downloadId: String, filename: String) {
        let taskIdentifier = "\(baseId).\(downloadId.md5)"
        
        if !registeredTasks.contains(taskIdentifier) {
            BGTaskScheduler.shared.register(forTaskWithIdentifier: taskIdentifier, using: nil) { task in
                guard let task = task as? BGContinuedProcessingTask else { return }
                self.activeTasks[task.identifier] = task
                
                task.expirationHandler = {
                    if let download = DownloadManager.shared.getDownload(by: downloadId) {
                        DownloadManager.shared.cancelDownload(download)
                    }
                    self.activeTasks.removeValue(forKey: task.identifier)
                }
            }
            self.registeredTasks.insert(taskIdentifier)
        }
        
        let request = BGContinuedProcessingTaskRequest(identifier: taskIdentifier, title: filename, subtitle: .localized("Downloading"))
        request.strategy = .queue
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print(error)
        }
    }
    
    func updateProgress(for downloadId: String, progress: Double) {
        let taskIdentifier = "\(baseId).\(downloadId.md5)"
        
        guard let task = activeTasks[taskIdentifier] else { return }
        task.progress.totalUnitCount = 100
        task.progress.completedUnitCount = Int64(progress * 100)
        
        task.updateTitle(task.title, subtitle: "\(Int(progress * 100))%")
        
        if task.progress.completedUnitCount == task.progress.totalUnitCount {
            stopTask(for: downloadId, success: true)
        }
    }
    
    func stopTask(for downloadId: String, success: Bool) {
        let taskIdentifier = "\(baseId).\(downloadId.md5)"
        guard let task = activeTasks[taskIdentifier] else { return }
        
        task.setTaskCompleted(success: success)
        activeTasks.removeValue(forKey: taskIdentifier)
    }
}

extension String {
    var md5: String {
        Insecure.MD5.hash(data: Data(self.utf8)).map { String(format: "%02hhx", $0) }.joined()
    }
}
