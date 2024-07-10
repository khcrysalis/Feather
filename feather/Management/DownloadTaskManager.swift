//
//  test.swift
//  feather
//
//  Created by samara on 7/9/24.
//

import Foundation

enum DownloadState {
	case notStarted
	case inProgress(progress: CGFloat)
	case completed
	case failed(error: Error)
	
	var progress: CGFloat? {
		switch self {
		case .inProgress(let progress):
			return progress
		default:
			return nil
		}
	}
}

class DownloadTask {
	var uuid: String
	var cell: SourceAppTableViewCell
	var state: DownloadState
	var progressHandler: ((CGFloat) -> Void)?
	
	init(uuid: String, cell: SourceAppTableViewCell, state: DownloadState = .notStarted) {
		self.uuid = uuid
		self.cell = cell
		self.state = state
	}
	
	func updateProgress(to progress: CGFloat) {
		state = .inProgress(progress: progress)
		progressHandler?(progress)
		NotificationCenter.default.post(name: .downloadProgressUpdated, object: self, userInfo: ["uuid": uuid, "progress": progress])
	}
}

extension Notification.Name {
	static let downloadProgressUpdated = Notification.Name("downloadProgressUpdated")
}

class DownloadTaskManager {
	static let shared = DownloadTaskManager()
	public var downloadTasks: [String: DownloadTask] = [:]
	private init() { }
	
	func addTask(uuid: String, cell: SourceAppTableViewCell) {
		let task = DownloadTask(uuid: uuid, cell: cell)
		downloadTasks[uuid] = task
		print(downloadTasks)
	}
	
	func updateTask(uuid: String, state: DownloadState) {
		guard let task = downloadTasks[uuid] else { return }
		task.state = state
		persistTaskState(task)
		switch state {
		case .inProgress(let progress):
			task.cell.updateProgress(to: progress)
		case .completed:
			task.cell.stopDownload()
			removeTask(uuid: uuid)
			removePersistedTaskState(for: uuid)
		case .failed:
			task.cell.stopDownload()
			removeTask(uuid: uuid)
			removePersistedTaskState(for: uuid)
		default:
			break
		}
	}
	
	func cancelDownload(for uuid: String) {
		guard let task = downloadTasks[uuid] else { return }
		task.cell.cancelDownload()
		removeTask(uuid: uuid)
	}
	
	func updateTaskProgress(uuid: String, progress: CGFloat) {
		guard let task = downloadTasks[uuid] else { return }
		task.updateProgress(to: progress)
	}
	
	func removeTask(uuid: String) {
		downloadTasks.removeValue(forKey: uuid)
		removePersistedTaskState(for: uuid)
	}
	
	func task(for uuid: String) -> DownloadTask? {
		return downloadTasks[uuid]
	}
	
	private func persistTaskState(_ task: DownloadTask) {
		let defaults = UserDefaults.standard
		defaults.set(task.state.progress, forKey: "\(task.uuid)_progress")
	}
	
	private func removePersistedTaskState(for uuid: String) {
		let defaults = UserDefaults.standard
		defaults.removeObject(forKey: "\(uuid)_progress")
	}
	
	func restoreTaskState(for uuid: String, cell: SourceAppTableViewCell) {
		let defaults = UserDefaults.standard
		if let progress = defaults.value(forKey: "\(uuid)_progress") as? CGFloat {
			let task = DownloadTask(uuid: uuid, cell: cell, state: .inProgress(progress: progress))
			downloadTasks[uuid] = task
		}
	}
}
