//
//  LogsViewController.swift
//  feather
//
//  Created by samara on 22.10.2024.
//

import UIKit

class LogsViewController: UIViewController {
	var tableView: UITableView!
	private var logTextView: UITextView!
	private var logFileObserver: DispatchSourceFileSystemObject?
	private var currentFileSize: UInt64 = 0
	private var errCount = 0
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupNavigation()
		setupViews()
		startObservingLogFile()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(false)
		parseLogFile()
		tableView.reloadSections(IndexSet([0]), with: .automatic)
	}
	
	fileprivate func setupNavigation() {
		self.navigationItem.largeTitleDisplayMode = .never
	}
	
	fileprivate func setupViews() {
		view.backgroundColor = .systemBackground
		logTextView = UITextView()
		logTextView.isEditable = false
		logTextView.translatesAutoresizingMaskIntoConstraints = false
		logTextView.font = UIFont.monospacedSystemFont(ofSize: 10, weight: .regular)
		logTextView.textContainerInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
		view.addSubview(logTextView)
		
		self.tableView = UITableView(frame: .zero, style: .insetGrouped)
		self.tableView.translatesAutoresizingMaskIntoConstraints = false
		self.tableView.dataSource = self
		self.tableView.delegate = self
		self.tableView.backgroundColor = .background
		
		self.tableView.layer.cornerRadius = 12
		self.tableView.layer.cornerCurve = .continuous
		self.tableView.layer.masksToBounds = true
		
		self.view.addSubview(tableView)
		
		NSLayoutConstraint.activate([
			logTextView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
			logTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			logTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			logTextView.heightAnchor.constraint(equalToConstant: 400),
			
			tableView.topAnchor.constraint(equalTo: logTextView.bottomAnchor),
			tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
		])
		
		loadInitialLogContents()
	}
	
	private func loadInitialLogContents() {
		let logFilePath = getDocumentsDirectory().appendingPathComponent("logs.txt")
		
		guard let fileHandle = try? FileHandle(forReadingFrom: logFilePath) else {
			logTextView.text = "Failed to open logs"
			return
		}
		
		let data = fileHandle.readDataToEndOfFile()
		logTextView.text = String(data: data, encoding: .utf8) ?? "Failed to load logs"
		currentFileSize = UInt64(data.count)
		
		fileHandle.closeFile()
	}
	
	private func startObservingLogFile() {
		let logFilePath = getDocumentsDirectory().appendingPathComponent("logs.txt").path
		
		let fileDescriptor = open(logFilePath, O_EVTONLY)
		if fileDescriptor == -1 {
			print("Failed to open file for observation")
			return
		}
		
		let source = DispatchSource.makeFileSystemObjectSource(fileDescriptor: fileDescriptor, eventMask: .write, queue: DispatchQueue.main)
		source.setEventHandler { [weak self] in
			self?.loadNewLogContents()
		}
		source.setCancelHandler {
			close(fileDescriptor)
		}
		source.resume()
		logFileObserver = source
	}
	
	private func loadNewLogContents() {
		let logFilePath = getDocumentsDirectory().appendingPathComponent("logs.txt")
		
		guard let fileHandle = try? FileHandle(forReadingFrom: logFilePath) else {
			logTextView.text.append("\nFailed to read logs")
			return
		}
		
		fileHandle.seek(toFileOffset: currentFileSize)
		
		let newData = fileHandle.readDataToEndOfFile()
		if let newContent = String(data: newData, encoding: .utf8) {
			logTextView.text.append(newContent)
			let range = NSMakeRange(logTextView.text.count - 1, 0)
			logTextView.scrollRangeToVisible(range)
			scrollToBottom()
		}
		
		currentFileSize += UInt64(newData.count)
		
		fileHandle.closeFile()
	}
	
	deinit {
		logFileObserver?.cancel()
	}
	
	private func scrollToBottom() {
		let bottomRange = NSMakeRange(logTextView.text.count - 1, 1)
		logTextView.scrollRangeToVisible(bottomRange)
	}
	
	private func parseLogFile() {
		let logFilePath = getDocumentsDirectory().appendingPathComponent("logs.txt")
		do {
			let logContents = try String(contentsOf: logFilePath)

			let logEntries = logContents.components(separatedBy: .newlines)

			for entry in logEntries {
				if entry.contains("🔍") {
					errCount += 1
				} else if entry.contains("⚠️") {
					errCount += 1
				} else if entry.contains("❌") {
					errCount += 1
				} else if entry.contains("🔥") {
					errCount += 1
				}
			}

		} catch {
			Debug.shared.log(message: "Error reading log file: \(error)")
		}
	}
	
	
}

extension LogsViewController: UITableViewDataSource, UITableViewDelegate {
	func numberOfSections(in tableView: UITableView) -> Int { return 2 }
	func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat { return 0 }
	
	func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
		let headerView = InsetGroupedSectionHeader(title: "")
		return headerView
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch section {
		case 0: return 1
		case 1: return 2
		default:
			return 0
		}
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let reuseIdentifier = "Cell"
		let cell = UITableViewCell(style: .value1, reuseIdentifier: reuseIdentifier)
		cell.accessoryType = .none
		cell.selectionStyle = .none

		switch (indexPath.section, indexPath.row) {
		case (0, 0):
			cell.textLabel?.text = "\(errCount) Critical Errors."
			cell.textLabel?.textColor = .white
			cell.textLabel?.font = .boldSystemFont(ofSize: 14)
			cell.backgroundColor = .systemRed
		case (1, 0):
			cell.textLabel?.text = "Share Logs"
			cell.textLabel?.textColor = .tintColor
			cell.selectionStyle = .default
			cell.setAccessoryIcon(with: "square.and.arrow.up")
		case (1, 1):
			cell.textLabel?.text = "Copy Logs"
			cell.textLabel?.textColor = .tintColor
			cell.selectionStyle = .default
			cell.setAccessoryIcon(with: "arrow.up.right")
		default:
			print("ball")
		}
		
		return cell
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		switch (indexPath.section, indexPath.row) {
		case (1, 0):
			let logFilePath = getDocumentsDirectory().appendingPathComponent("logs.txt")
			let activityVC = UIActivityViewController(activityItems: [logFilePath], applicationActivities: nil)
			
			if let sheet = activityVC.sheetPresentationController {
				sheet.detents = [.medium()]
				sheet.prefersGrabberVisible = true
			}
			
			present(activityVC, animated: true)
		case (1, 1):
			let logFilePath = getDocumentsDirectory().appendingPathComponent("logs.txt")
			
			do {
				let logContents = try String(contentsOf: logFilePath, encoding: .utf8)
				UIPasteboard.general.string = logContents
				let alert = UIAlertController(title: "Copied", message: "Log contents have been copied to clipboard.", preferredStyle: .alert)
				alert.addAction(UIAlertAction(title: "OK", style: .default))
				present(alert, animated: true)
			} catch {
				let alert = UIAlertController(title: "Error", message: "Failed to copy log contents.", preferredStyle: .alert)
				alert.addAction(UIAlertAction(title: "OK", style: .default))
				present(alert, animated: true)
			}
		default:
			break
		}
		tableView.deselectRow(at: indexPath, animated: true)
	}
}
