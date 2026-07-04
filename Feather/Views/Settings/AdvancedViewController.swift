//
//  AdvancedViewController.swift
//  Feather
//
//  Created by samsam on 5/24/26.
//

import UIKit
import Nuke

class AdvancedViewController: ThemedTableViewController {
	override func viewDidLoad() {
		super.viewDidLoad()
		title = .localized("Advanced")
	}
}

extension AdvancedViewController {
	override func numberOfSections(in tableView: UITableView) -> Int {
		2
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch section {
		case 0: 1
		case 1: 7
		default: 0
		}
	}
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		if section == 1 { "Advanced" } else { nil }
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(
			withIdentifier: "Cell",
			for: indexPath
		)

		var content = cell.defaultContentConfiguration()
		cell.accessoryType = .none
		cell.accessoryView = nil
		content.textProperties.color = .tintColor
		cell.accessoryType = .disclosureIndicator

		switch (indexPath.section, indexPath.row) {
		case (0, 0):
			content.text = "Run in background"
			content.textProperties.color = .label
			
			let toggle = UISwitch()
			toggle.isOn = UserDefaults.standard.bool(forKey: "Feather.stayInBackground")
			toggle.addTarget(self, action: #selector(_stayInBackgroundSwitchChanged(_:)), for: .valueChanged)
			cell.accessoryView = toggle
			cell.accessoryType = .none
			cell.selectionStyle = .none
		case (1, 0): content.text = "Clear Caches"
		case (1, 1): content.text = "Clear Sources"
		case (1, 2): content.text = "Clear Signed Apps"
		case (1, 3): content.text = "Clear Imported Apps"
		case (1, 4): content.text = "Clear Certificates"
		case (1, 5): content.text = "Reset Settings"
		case (1, 6): content.text = "Reset"
		default: break
		}

		cell.contentConfiguration = content
		return cell
	}
	
	@objc private func _stayInBackgroundSwitchChanged(_ sender: UISwitch) {}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		switch (indexPath.section, indexPath.row) {
		case (0, 0): return
		case (1, 0):
			_resetAlert(title: "Clear Caches", message: _cacheSize()) {
				_clearCaches()
			}
		case (1, 1):
			_resetAlert(title: "Clear Sources", message: Storage.shared.countContent(for: AltSource.self)) {
				_clearSources()
			}
		case (1, 2):
			_resetAlert(title: "Clear Signed Apps", message: Storage.shared.countContent(for: Signed.self)) {
				_clearSources()
			}
		case (1, 3):
			_resetAlert(title: "Clear Imported Apps", message: Storage.shared.countContent(for: Imported.self)) {
				_clearSources()
			}
		case (1, 4):
			_resetAlert(title: "Clear Certificates", message: Storage.shared.countContent(for: CertificatePair.self)) {
				_clearSources()
			}
		case (1, 5):
			_resetAlert(title: "Reset Settings") {
				_resetSettings()
			}
		case (1, 6):
			_resetAlert(title: "Reset") {
				_resetAll()
			}
		default: break
		}
		
		tableView.deselectRow(at: indexPath, animated: true)
	}
}

fileprivate func _resetAlert(
	title: String,
	message: String = "",
	action: @escaping () -> Void
) {
	let action = UIAlertAction(
		title: "Continue",
		style: .destructive
	) { _ in
		action()
		UIApplication.shared.suspendAndReopen()
	}
	
	let style: UIAlertController.Style = UIDevice.current.userInterfaceIdiom == .pad
		? .alert
		: .actionSheet
	
	var msg = ""
	if !message.isEmpty { msg = message + "\n" }
	msg.append(.localized("This action cannot be undone. Would you like to proceed?"))

	UIAlertController.showAlertWithCancel(
		title: title,
		message: msg,
		style: style,
		actions: [action]
	)
}

fileprivate func _cacheSize() -> String {
	var totalCacheSize = URLCache.shared.currentDiskUsage
	if let nukeCache = ImagePipeline.shared.configuration.dataCache as? DataCache {
		totalCacheSize += nukeCache.totalSize
	}
	return "\(ByteCountFormatter.string(fromByteCount: Int64(totalCacheSize), countStyle: .file))"
}

fileprivate func _clearCaches() {
	URLCache.shared.removeAllCachedResponses()
	HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
	
	if let dataCache = ImagePipeline.shared.configuration.dataCache as? DataCache {
		dataCache.removeAll()
	}
	
	if let imageCache = ImagePipeline.shared.configuration.imageCache as? Nuke.ImageCache {
		imageCache.removeAll()
	}
}

fileprivate func _clearSources() {
	Storage.shared.clearContext(request: AltSource.fetchRequest())
}

fileprivate func _clearSignedApps() {
	Storage.shared.clearContext(request: Signed.fetchRequest())
	try? FileManager.default.removeFileIfNeeded(at: FileManager.default.signed)
}

fileprivate func _clearImportedApps() {
	Storage.shared.clearContext(request: Imported.fetchRequest())
	try? FileManager.default.removeFileIfNeeded(at: FileManager.default.unsigned)
}

fileprivate func _clearCertificates(resetAll: Bool = false) {
	if !resetAll { UserDefaults.standard.set(0, forKey: "feather.selectedCert") }
	Storage.shared.clearContext(request: CertificatePair.fetchRequest())
	try? FileManager.default.removeFileIfNeeded(at: FileManager.default.certificates)
}

fileprivate func _resetSettings() {
	UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
}

fileprivate func _resetAll() {
	_clearCaches()
	_clearSources()
	_clearSignedApps()
	_clearImportedApps()
	_clearCertificates(resetAll: true)
	_resetSettings()
}
