//
//  ResetViewController.swift
//  feather
//
//  Created by samara on 7/10/24.
//  Copyright (c) 2024 Samara M (khcrysalis)
//

import UIKit
import Nuke

class ResetViewController: UITableViewController {
	let tintColor = Preferences.appTintColor.uiColor
	var tableData =
	[
		["Clear Network Cache"]
	]
	
	var sectionTitles =
	[
		""
	]
	
	init() { super.init(style: .insetGrouped) }
	required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(false)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupViews()
		setupNavigation()
	}
	
	fileprivate func setupViews() {
		self.tableView.dataSource = self
		self.tableView.delegate = self
	}
	
	fileprivate func setupNavigation() {
		self.title = "Reset"
		self.navigationItem.largeTitleDisplayMode = .never
	}
}

extension ResetViewController {
	override func numberOfSections(in tableView: UITableView) -> Int { return sectionTitles.count }
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return tableData[section].count}
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? { return sectionTitles[section] }
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let reuseIdentifier = "Cell"
		let cell = UITableViewCell(style: .value1, reuseIdentifier: reuseIdentifier)
		cell.accessoryType = .none
		cell.selectionStyle = .default
		
		let cellText = tableData[indexPath.section][indexPath.row]
		cell.textLabel?.text = cellText
		
		switch cellText {
		case "Clear Network Cache":
			cell.textLabel?.textColor = Preferences.appTintColor.uiColor
		case "Reset Settings":
			cell.textLabel?.textColor = UIColor.systemRed
		default:
			break
		}
		
		return cell
	}


	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let itemTapped = tableData[indexPath.section][indexPath.row]
		switch itemTapped {
		case "Clear Network Cache":
			var totalCacheSize = URLCache.shared.currentDiskUsage
			if let nukeCache = ImagePipeline.shared.configuration.dataCache as? DataCache {
				totalCacheSize += nukeCache.totalSize
			}
			let message = "This action is irreversible. Cached network requests and images will be cleared."
			+ "\n\n"
			+ String("Cache size: \(ByteCountFormatter.string(fromByteCount: Int64(totalCacheSize), countStyle: .file))")
			
			confirmAction(
				title: "Clear Network Cache",
				message: message
			) {
				self.clearNetworkCache()
			}
			
		case "Reset Settings":
			confirmAction(
				title: "Reset Settings",
				message: "This action is irreversible. Preferences will be reset.\n\nTHIS WILL ALSO RESET"
			) {
				self.resetSettings()
			}
		default:
			break
		}
		
		tableView.deselectRow(at: indexPath, animated: true)
	}
	
	func confirmAction(
		title: String,
		message: String,
		continueActionName: String = "Continue",
		destructive: Bool = true,
		proceed: @escaping () -> Void
	) {
		let alertView = UIAlertController(
			title: title,
			message: message,
			preferredStyle: UIDevice.current.userInterfaceIdiom == .pad ? .alert : .actionSheet
		)

		let action = UIAlertAction(title: continueActionName, style: destructive ? .destructive : .default) { _ in proceed() }
		alertView.addAction(action)

		alertView.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel))
		present(alertView, animated: true)
	}

	
}

// MARK: - Data Clearing Methods
extension ResetViewController {

	func clearNetworkCache() {
		URLCache.shared.removeAllCachedResponses()
		HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
		
		if let dataCache = ImagePipeline.shared.configuration.dataCache as? DataCache {
			dataCache.removeAll()
		}
		
		if let imageCache = ImagePipeline.shared.configuration.imageCache as? Nuke.ImageCache {
			imageCache.removeAll()
		}
	}

	func resetSettings() {
		if let bundleID = Bundle.main.bundleIdentifier {
			UserDefaults.standard.removePersistentDomain(forName: bundleID)
		}
	}
}
