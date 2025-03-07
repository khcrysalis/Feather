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

class SettingsViewController: FRSTableViewController {
	let aboutSection = [
		String.localized("SETTINGS_VIEW_CONTROLLER_CELL_ABOUT", arguments: "Feather"),
		String.localized("SETTINGS_VIEW_CONTROLLER_CELL_SUBMIT_FEEDBACK"),
		String.localized("SETTINGS_VIEW_CONTROLLER_CELL_GITHUB")
	]

	let displaySection = [
		String.localized("SETTINGS_VIEW_CONTROLLER_CELL_DISPLAY"),
		String.localized("SETTINGS_VIEW_CONTROLLER_CELL_APP_ICON")
	]

	let certificateSection = [
		"Current Certificate",
		String.localized("SETTINGS_VIEW_CONTROLLER_CELL_ADD_CERTIFICATES"),
		String.localized("SETTINGS_VIEW_CONTROLLER_CELL_SIGN_OPTIONS"),
		String.localized("SETTINGS_VIEW_CONTROLLER_CELL_SERVER_OPTIONS")
	]

	let logsSection = [
		String.localized("SETTINGS_VIEW_CONTROLLER_CELL_VIEW_LOGS")
	]

	let foldersSection = [
		String.localized("SETTINGS_VIEW_CONTROLLER_CELL_APPS_FOLDER"),
		String.localized("SETTINGS_VIEW_CONTROLLER_CELL_CERTS_FOLDER")
	]

	let resetSection = [
		String.localized("SETTINGS_VIEW_CONTROLLER_CELL_RESET"),
		String.localized("SETTINGS_VIEW_CONTROLLER_CELL_RESET_ALL")
	]
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		tableData = {
			return [
				aboutSection,
				displaySection,
				certificateSection,
				logsSection,
				foldersSection,
				resetSection
			]
		}()
		
		
		sectionTitles =
		[
			"",
			"",
			"",
			"",
			"",
			"",
			"",
		]
		ensureTableDataHasSections()
		seeIfDonateShouldAppear()
		setupNavigation()
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
		self.tableView.reloadData()
	}

	fileprivate func setupNavigation() {
		self.title = String.localized("TAB_SETTINGS")
	}
}

extension SettingsViewController {
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
		case String.localized("SETTINGS_VIEW_CONTROLLER_CELL_ADD_CERTIFICATES"):
			cell.setAccessoryIcon(with: "plus")
			cell.selectionStyle = .default
		case String.localized("SETTINGS_VIEW_CONTROLLER_CELL_SIGN_OPTIONS"):
			cell.setAccessoryIcon(with: "signature")
			cell.selectionStyle = .default
		case String.localized("SETTINGS_VIEW_CONTROLLER_CELL_SERVER_OPTIONS"):
			cell.setAccessoryIcon(with: "server.rack")
			cell.selectionStyle = .default
			
		case String.localized("SETTINGS_VIEW_CONTROLLER_CELL_VIEW_LOGS"):
			cell.setAccessoryIcon(with: "newspaper")
			cell.selectionStyle = .default
			
		case String.localized("SETTINGS_VIEW_CONTROLLER_CELL_APPS_FOLDER"),
			String.localized("SETTINGS_VIEW_CONTROLLER_CELL_CERTS_FOLDER"):
			cell.accessoryType = .disclosureIndicator
			cell.textLabel?.textColor = .tintColor
			cell.selectionStyle = .default
			
		case String.localized("SETTINGS_VIEW_CONTROLLER_CELL_RESET"), 
			String.localized("SETTINGS_VIEW_CONTROLLER_CELL_RESET_ALL"):
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
			
		case String.localized("SETTINGS_VIEW_CONTROLLER_CELL_ADD_CERTIFICATES"):
			let l = CertificatesViewController()
			navigationController?.pushViewController(l, animated: true)
		case String.localized("SETTINGS_VIEW_CONTROLLER_CELL_SIGN_OPTIONS"):
			let signingDataWrapper = SigningDataWrapper(signingOptions: UserDefaults.standard.signingOptions)
			let l = SigningsOptionViewController(signingDataWrapper: signingDataWrapper)
			navigationController?.pushViewController(l, animated: true)
		case String.localized("SETTINGS_VIEW_CONTROLLER_CELL_SERVER_OPTIONS"):
			let l = ServerOptionsViewController()
			navigationController?.pushViewController(l, animated: true)
			
		case String.localized("SETTINGS_VIEW_CONTROLLER_CELL_VIEW_LOGS"):
			let l = LogsViewController()
			navigationController?.pushViewController(l, animated: true)
			
		case String.localized("SETTINGS_VIEW_CONTROLLER_CELL_APPS_FOLDER"):
			openDirectory(named: "Apps")
		case String.localized("SETTINGS_VIEW_CONTROLLER_CELL_CERTS_FOLDER"):
			openDirectory(named: "Certificates")
			
		case String.localized("SETTINGS_VIEW_CONTROLLER_CELL_RESET"):
			self.resetOptionsAction()
		case String.localized("SETTINGS_VIEW_CONTROLLER_CELL_RESET_ALL"):
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

