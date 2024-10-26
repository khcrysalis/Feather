//
//  SettingsViewController.swift
//  feather
//
//  Created by samara on 7/7/24.
//  Copyright (c) 2024 Samara M (khcrysalis)
//

import UIKit
import Nuke
import SwiftUI

class SettingsViewController: UITableViewController {
	var tableData =
	[
		[
			String.localized("SETTINGS_VIEW_CONTROLLER_CELL_ABOUT", arguments: "Feather"),
			String.localized("SETTINGS_VIEW_CONTROLLER_CELL_SUBMIT_FEEDBACK"),
			String.localized("SETTINGS_VIEW_CONTROLLER_CELL_GITHUB")
		],
		[
			String.localized("SETTINGS_VIEW_CONTROLLER_CELL_DISPLAY"),
			String.localized("SETTINGS_VIEW_CONTROLLER_CELL_APP_ICON")
		],
		[
			"Language",
		],
		[
			"Current Certificate",
			"Certificates",
			"Signing Options",
			"Server Options",
		],
		[
			"View Logs",
		],
		[
			"Open Apps Folder",
			"Open Certificates Folder",
		],
		[
			"Reset",
			"Reset All",
		]
	]

	var sectionTitles =
	[
		"",
		"General",
		"",
		"Signing",
		"Debug",
		"",
		"",
	]
	
	var isDownloadingCertifcate = false
	
	init() { super.init(style: .insetGrouped) }
	required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(false)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupViews()
		seeIfDonateShouldAppear()
//		updateCells()
	}
	
	fileprivate func seeIfDonateShouldAppear() {
		if !Preferences.beta {
			let donateSection = ["Donate"]
			tableData.insert(donateSection, at: 0)
			sectionTitles.insert("", at: 0)
		}
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		setupNavigation()
		self.tableView.reloadData()
	}
	
	fileprivate func setupViews() {
		self.tableView.dataSource = self
		self.tableView.delegate = self
	}
	
	fileprivate func setupNavigation() {
		self.navigationController?.navigationBar.prefersLargeTitles = true
		self.title = String.localized("TAB_SETTINGS")
	}
}

extension SettingsViewController {
	override func numberOfSections(in tableView: UITableView) -> Int { return sectionTitles.count }
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return tableData[section].count }
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? { return sectionTitles[section] }
	override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat { return sectionTitles[section].isEmpty ? 0 : 40 }
	
	override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let title = sectionTitles[section]
		let headerView = InsetGroupedSectionHeader(title: title)
		return headerView
	}
	
	override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		if Preferences.beta && section == 0 {
			return String.localized("SETTINGS_VIEW_CONTROLLER_SECTION_FOOTER_ISSUES")
		} else if !Preferences.beta && section == 1 {
			return String.localized("SETTINGS_VIEW_CONTROLLER_SECTION_FOOTER_ISSUES")
		}
		
		switch section {
		case sectionTitles.count - 1: return "Feather \(AppDelegate().logAppVersionInfo()) • iOS \(UIDevice.current.systemVersion)"
		default:
			return nil
		}
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let reuseIdentifier = "Cell"
		var cell = UITableViewCell(style: .value1, reuseIdentifier: reuseIdentifier)
		cell.accessoryType = .none
		cell.selectionStyle = .none
		
		let cellText = tableData[indexPath.section][indexPath.row]
		cell.textLabel?.text = cellText
		
		switch cellText {
		case "Donate":
			cell = DonationTableViewCell(style: .default, reuseIdentifier: "D")
			cell.selectionStyle = .none
			
		case String.localized("SETTINGS_VIEW_CONTROLLER_CELL_ABOUT", arguments: "Feather"):
			cell.setAccessoryIcon(with: "info.circle")
			cell.selectionStyle = .default
		case String.localized("SETTINGS_VIEW_CONTROLLER_CELL_SUBMIT_FEEDBACK"), String.localized("SETTINGS_VIEW_CONTROLLER_CELL_GITHUB"):
			cell.textLabel?.textColor = .tintColor
			cell.setAccessoryIcon(with: "safari")
			cell.selectionStyle = .default
			
		case String.localized("SETTINGS_VIEW_CONTROLLER_CELL_DISPLAY"):
			cell.setAccessoryIcon(with: "paintbrush")
			cell.selectionStyle = .default
		case String.localized("SETTINGS_VIEW_CONTROLLER_CELL_APP_ICON"):
			cell.setAccessoryIcon(with: "app.dashed")
			cell.selectionStyle = .default
			
		case "Language":
			cell.setAccessoryIcon(with: "character.bubble")
			cell.selectionStyle = .default
			
		case "Current Certificate":
			if let hasGotCert = CoreDataManager.shared.getCurrentCertificate() {
				let cell = CertificateViewTableViewCell()
				cell.configure(with: hasGotCert, isSelected: false)
				cell.selectionStyle = .none
				return cell
			} else {
				cell.textLabel?.text = String.localized("SETTINGS_VIEW_CONTROLLER_CELL_CURRENT_CERTIFICATE_NOSELECTED")
				cell.textLabel?.textColor = .secondaryLabel
				cell.selectionStyle = .none
			}
		case "Certificates":
			cell.setAccessoryIcon(with: "rectangle.dashed.and.paperclip")
			cell.selectionStyle = .default
		case "Signing Options":
			cell.setAccessoryIcon(with: "signature")
			cell.selectionStyle = .default
		case "Server Options":
			cell.setAccessoryIcon(with: "server.rack")
			cell.selectionStyle = .default
			
		case "View Logs":
			cell.setAccessoryIcon(with: "newspaper")
			cell.selectionStyle = .default
			
		case "Open Apps Folder",
			 "Open Certificates Folder":
			cell.accessoryType = .disclosureIndicator
			cell.textLabel?.textColor = .tintColor
			cell.selectionStyle = .default
			
		case String.localized("SETTINGS_VIEW_CONTROLLER_CELL_RESET"), 
			 "Reset All":
			cell.textLabel?.textColor = .tintColor
			cell.accessoryType = .disclosureIndicator
			cell.selectionStyle = .default
			
		default:
			break
		}
		
		return cell
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let itemTapped = tableData[indexPath.section][indexPath.row]
		switch itemTapped {
		case String.localized("SETTINGS_VIEW_CONTROLLER_CELL_ABOUT", arguments: "Feather"):
			let l = AboutViewController()
			navigationController?.pushViewController(l, animated: true)
		case String.localized("SETTINGS_VIEW_CONTROLLER_CELL_GITHUB"):
			guard let url = URL(string: "https://github.com/khcrysalis/Feather") else {
				Debug.shared.log(message: "Invalid URL")
				return
			}
			UIApplication.shared.open(url, options: [:], completionHandler: nil)
		case String.localized("SETTINGS_VIEW_CONTROLLER_CELL_SUBMIT_FEEDBACK"):
			guard let url = URL(string: "https://github.com/khcrysalis/Feather/issues") else {
				Debug.shared.log(message: "Invalid URL")
				return
			}
			UIApplication.shared.open(url, options: [:], completionHandler: nil)
			
		case String.localized("SETTINGS_VIEW_CONTROLLER_CELL_DISPLAY"):
			let l = DisplayViewController()
			navigationController?.pushViewController(l, animated: true)
		case String.localized("SETTINGS_VIEW_CONTROLLER_CELL_APP_ICON"):
			let l = IconsListViewController()
			navigationController?.pushViewController(l, animated: true)
			
		case "Language":
			let l = PreferredLanguageViewController()
			navigationController?.pushViewController(l, animated: true)
			
		case "Certificates":
			let l = CertificatesViewController()
			navigationController?.pushViewController(l, animated: true)
		case "Signing Options":
			let l = SigningViewHostingController()
			navigationController?.pushViewController(l, animated: true)
		case "Server Options":
			let l = ServerOptionsViewController()
			navigationController?.pushViewController(l, animated: true)
			
		case "View Logs":
			let l = LogsViewController()
			navigationController?.pushViewController(l, animated: true)
			
		case "Open Apps Folder":
			openDirectory(named: "Apps")
		case "Open Certificates Folder":
			openDirectory(named: "Certificates")
			
		case String.localized("SETTINGS_VIEW_CONTROLLER_CELL_RESET"):
			self.resetOptionsAction()
		case "Reset All":
			self.resetAllAction()
		default:
			break
		}
		
		tableView.deselectRow(at: indexPath, animated: true)
	}
	
}

extension UITableViewCell {
	func setAccessoryIcon(with symbolName: String, tintColor: UIColor = .tertiaryLabel, renderingMode: UIImage.RenderingMode = .alwaysOriginal) {
		if let image = UIImage(systemName: symbolName)?.withTintColor(tintColor, renderingMode: renderingMode) {
			let imageView = UIImageView(image: image)
			self.accessoryView = imageView
		} else {
			self.accessoryView = nil
		}
	}
}

extension SettingsViewController {
	fileprivate func openDirectory(named directoryName: String) {
		let directoryURL = getDocumentsDirectory().appendingPathComponent(directoryName)
		let path = directoryURL.absoluteString.replacingOccurrences(of: "file://", with: "shareddocuments://")
		
		UIApplication.shared.open(URL(string: path)!, options: [:]) { success in
			if success {
				Debug.shared.log(message: "File opened successfully.")
			} else {
				Debug.shared.log(message: "Failed to open file.")
			}
		}
	}
}

