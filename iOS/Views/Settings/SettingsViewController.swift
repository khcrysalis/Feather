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
		["Donate"],
		[String.localized("SETTINGS_VIEW_CONTROLLER_CELL_ABOUT", arguments: "Feather"), String.localized("SETTINGS_VIEW_CONTROLLER_CELL_SUBMIT_FEEDBACK"), String.localized("SETTINGS_VIEW_CONTROLLER_CELL_GITHUB")],
		[String.localized("SETTINGS_VIEW_CONTROLLER_CELL_DISPLAY"), String.localized("SETTINGS_VIEW_CONTROLLER_CELL_APP_ICON")],
		["Current Certificate", String.localized("SETTINGS_VIEW_CONTROLLER_CELL_ADD_CERTIFICATES"), "Auto Install"],
//		["Signing Configuration"],
		["Fuck PPQCheck", "PPQCheckMitigationString", "PPQCheckMitigationExport"],
		["Use Server", String.localized("SETTINGS_VIEW_CONTROLLER_CELL_USE_CUSTOM_SERVER")],
		[String.localized("SETTINGS_VIEW_CONTROLLER_CELL_UPDATE_LOCAL_CERTIFICATE")],
		[
//			"Debug Logs",
			String.localized("SETTINGS_VIEW_CONTROLLER_CELL_RESET")
		]
	]
	
	var sectionTitles =
	[
		"",
		"",
		String.localized("SETTINGS_VIEW_CONTROLLER_SECTION_TITLE_GENERAL"),
		String.localized("SETTINGS_VIEW_CONTROLLER_SECTION_TITLE_SIGNING"),
//		"",
		"",
		String.localized("SETTINGS_VIEW_CONTROLLER_SECTION_TITLE_SIGNING_SERVER"),
//		"",
		String.localized("APP_SIGNING_VIEW_CONTROLLER_CELL_ADVANCED")
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
		updateCells()
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
	}
}

extension SettingsViewController {
	override func numberOfSections(in tableView: UITableView) -> Int { return sectionTitles.count }
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return tableData[section].count
	}
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? { return sectionTitles[section] }
	override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat { return sectionTitles[section].isEmpty ? 0 : 40 }
	
	override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let title = sectionTitles[section]
		let headerView = InsetGroupedSectionHeader(title: title)
		return headerView
	}
	
	override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		switch section {
		case 1:
			return String.localized("SETTINGS_VIEW_CONTROLLER_SECTION_FOOTER_ISSUES")
		case 5: return "Default server goes to \"\(Preferences.defaultInstallPath)\""
		case 6:
			return String.localized("SETTINGS_VIEW_CONTROLLER_SECTION_FOOTER_SERVER_LIMITATIONS")
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
		case "Debug Logs", "Signing Configuration":
			cell.accessoryType = .disclosureIndicator
			cell.selectionStyle = .default
		case String.localized("SETTINGS_VIEW_CONTROLLER_CELL_ABOUT", arguments: "Feather"):
			cell.setAccessoryIcon(with: "info.circle")
			cell.selectionStyle = .default
		case String.localized("SETTINGS_VIEW_CONTROLLER_CELL_DISPLAY"):
			cell.setAccessoryIcon(with: "paintbrush")
			cell.selectionStyle = .default
		case String.localized("SETTINGS_VIEW_CONTROLLER_CELL_SUBMIT_FEEDBACK"), String.localized("SETTINGS_VIEW_CONTROLLER_CELL_GITHUB"):
			cell.textLabel?.textColor = .tintColor
			cell.setAccessoryIcon(with: "safari")
			cell.selectionStyle = .default
		case String.localized("SETTINGS_VIEW_CONTROLLER_CELL_RESET"):
			cell.textLabel?.textColor = .tintColor
			cell.accessoryType = .disclosureIndicator
			cell.selectionStyle = .default
		case String.localized("SETTINGS_VIEW_CONTROLLER_CELL_ADD_CERTIFICATES"):
			cell.setAccessoryIcon(with: "plus")
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
		case "Auto Install":
			let autoInstall = SwitchViewCell()
			autoInstall.textLabel?.text = "Install after signing"
			autoInstall.switchControl.addTarget(self, action: #selector(autoInstallAfterSignToggled(_:)), for: .valueChanged)
			autoInstall.switchControl.isOn = Preferences.autoInstallAfterSign
			autoInstall.selectionStyle = .none
			return autoInstall
		case "Fuck PPQCheck":
			let fuckPPq = SwitchViewCell()
			fuckPPq.textLabel?.text = String.localized("SETTINGS_VIEW_CONTROLLER_PPQ_ALERT_TITLE")
			fuckPPq.switchControl.addTarget(self, action: #selector(fuckPpqcheckToggled(_:)), for: .valueChanged)
			fuckPPq.switchControl.isOn = Preferences.isFuckingPPqcheckDetectionOff
			fuckPPq.selectionStyle = .none

			let infoButton = UIButton(type: .infoLight)
			infoButton.addTarget(self, action: #selector(showPPQInfoAlert), for: .touchUpInside)
			fuckPPq.accessoryView = infoButton

			return fuckPPq

		case "PPQCheckMitigationString":
			cell.textLabel?.text = String.localized("SETTINGS_VIEW_CONTROLLER_CELL_CHANGE_ID")
			cell.textLabel?.textColor = .tintColor
			cell.selectionStyle = .default
		case "PPQCheckMitigationExport":
			cell.textLabel?.text = String.localized("SETTINGS_VIEW_CONTROLLER_CELL_EXPORT_ID")
			cell.textLabel?.textColor = .tintColor
			cell.selectionStyle = .default
		case "Use Server":
			let useS = SwitchViewCell()
			useS.textLabel?.text = String.localized("SETTINGS_VIEW_CONTROLLER_CELL_ONLINE_INSTALL_METHOD")
			useS.switchControl.addTarget(self, action: #selector(onlinePathToggled(_:)), for: .valueChanged)
			useS.switchControl.isOn = Preferences.userSelectedServer
			useS.selectionStyle = .none
			return useS
		case String.localized("SETTINGS_VIEW_CONTROLLER_CELL_USE_CUSTOM_SERVER"):
			if Preferences.onlinePath != Preferences.defaultInstallPath {
				cell.textLabel?.textColor = UIColor.systemGray
				cell.isUserInteractionEnabled = false
				cell.textLabel?.text = Preferences.onlinePath!
			} else {
				cell.textLabel?.textColor = .tintColor
			}
		case String.localized("SETTINGS_VIEW_CONTROLLER_CELL_RESET_CONFIGURATION"):
			cell.textLabel?.textColor = .systemRed
			cell.textLabel?.textAlignment = .center
		case String.localized("SETTINGS_VIEW_CONTROLLER_CELL_APP_ICON"):
			cell.setAccessoryIcon(with: "app.dashed")
			cell.selectionStyle = .default
		case String.localized("SETTINGS_VIEW_CONTROLLER_CELL_UPDATE_LOCAL_CERTIFICATE"):
			if !isDownloadingCertifcate {
				cell.textLabel?.textColor = .tintColor
				cell.setAccessoryIcon(with: "signature")
				cell.selectionStyle = .default
			} else {
				let cell = ActivityIndicatorViewCell()
				cell.activityIndicator.startAnimating()
				cell.selectionStyle = .none
				cell.textLabel?.text = String.localized("SETTINGS_VIEW_CONTROLLER_CELL_UPDATE_LOCAL_CERTIFICATE_UPDATING")
				cell.textLabel?.textColor = .secondaryLabel
				return cell
			}
			
		default:
			break
		}
		
		return cell
	}
	
	@objc func showPPQInfoAlert() {
		let alertController = UIAlertController(
			title: String.localized("SETTINGS_VIEW_CONTROLLER_PPQ_ALERT_TITLE"),
			message: String.localized("SETTINGS_VIEW_CONTROLLER_PPQ_ALERT_DESCRIPTION"),
			preferredStyle: .alert
		)
		alertController.addAction(UIAlertAction(title: String.localized("OK"), style: .cancel))
		present(alertController, animated: true, completion: nil)
	}
	
	@objc func onlinePathToggled(_ sender: UISwitch) {
		Preferences.userSelectedServer = sender.isOn
		
		let alertController = UIAlertController(
			title: "",
			message: "You must close the app for changes to take effect.",
			preferredStyle: .alert
		)
		
		let closeAction = UIAlertAction(title: String.localized("OK"), style: .default) { _ in
			CFPreferencesAppSynchronize(kCFPreferencesCurrentApplication)
			UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
			exit(0)
		}
		
		alertController.addAction(closeAction)
		present(alertController, animated: true, completion: nil)
	}
	
	@objc func fuckPpqcheckToggled(_ sender: UISwitch) {
		Preferences.isFuckingPPqcheckDetectionOff = sender.isOn
	}
    
	@objc func autoInstallAfterSignToggled(_ sender: UISwitch) {
		Preferences.autoInstallAfterSign = sender.isOn
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let itemTapped = tableData[indexPath.section][indexPath.row]
		switch itemTapped {
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
		case String.localized("SETTINGS_VIEW_CONTROLLER_CELL_ABOUT", arguments: "Feather"):
			let l = AboutViewController()
			navigationController?.pushViewController(l, animated: true)
		case String.localized("SETTINGS_VIEW_CONTROLLER_CELL_RESET"):
			let l = ResetViewController()
			navigationController?.pushViewController(l, animated: true)
		case String.localized("SETTINGS_VIEW_CONTROLLER_CELL_ADD_CERTIFICATES"):
			let l = CertificatesViewController()
			navigationController?.pushViewController(l, animated: true)
		case "PPQCheckMitigationString":
			showChangeIdentifierAlert()
		case  "PPQCheckMitigationExport":
			let shareText = Preferences.pPQCheckString
			let activityViewController = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
			present(activityViewController, animated: true, completion: nil)
		case String.localized("SETTINGS_VIEW_CONTROLLER_CELL_APP_ICON"):
			let iconsListViewController = IconsListViewController()
			navigationController?.pushViewController(iconsListViewController, animated: true)
		case String.localized("SETTINGS_VIEW_CONTROLLER_CELL_USE_CUSTOM_SERVER"):
			showChangeDownloadURLAlert()
		case String.localized("SETTINGS_VIEW_CONTROLLER_CELL_RESET_CONFIGURATION"):
			resetConfigDefault()
		case String.localized("SETTINGS_VIEW_CONTROLLER_CELL_UPDATE_LOCAL_CERTIFICATE"):
			if !isDownloadingCertifcate {
				isDownloadingCertifcate = true
				tableView.reloadRows(at: [indexPath], with: .automatic)
				
				downloadCertificatesOnline(from: [
					"https://github.com/khcrysalis/localhost.direct-retriever/raw/main/localhost.direct.pem", 
					"https://github.com/khcrysalis/localhost.direct-retriever/raw/main/localhost.direct.crt"
				]
				) { result in
					switch result {
					case .success(_):
						self.isDownloadingCertifcate = false
						DispatchQueue.main.async {
							Debug.shared.log(message: "File(s) successfully downloaded!", type: .success)
							tableView.reloadRows(at: [indexPath], with: .automatic)
						}
					case .failure(let error):
						self.isDownloadingCertifcate = false
						DispatchQueue.main.async {
							Debug.shared.log(message: "\(error)", type: .critical)
							tableView.reloadRows(at: [indexPath], with: .automatic)
						}
					}
				}
				
			}
			break
		default:
			break
		}
		
		tableView.deselectRow(at: indexPath, animated: true)
	}
	
	func updateCells() {
		if Preferences.onlinePath != Preferences.defaultInstallPath {
			tableData[5].insert(String.localized("SETTINGS_VIEW_CONTROLLER_CELL_RESET_CONFIGURATION"), at: 2)
		}
		Preferences.installPathChangedCallback = { [weak self] newInstallPath in
			self?.handleInstallPathChange(newInstallPath)
		}
	}
	
	private func handleInstallPathChange(_ newInstallPath: String?) {
		if newInstallPath != Preferences.defaultInstallPath {
			tableData[5].insert(String.localized("SETTINGS_VIEW_CONTROLLER_CELL_RESET_CONFIGURATION"), at: 2)
		} else {
			if let index = tableData[5].firstIndex(of: String.localized("SETTINGS_VIEW_CONTROLLER_CELL_RESET_CONFIGURATION")) {
				tableData[5].remove(at: index)
			}
		}

		tableView.reloadSections(IndexSet(integer: 5), with: .automatic)
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
	func resetConfigDefault() {
		Preferences.onlinePath = Preferences.defaultInstallPath
	}
	
	func showChangeDownloadURLAlert() {
		let alert = UIAlertController(title: String.localized("SETTINGS_VIEW_CONTROLLER_URL_ALERT_TITLE"), message: nil, preferredStyle: .alert)

		alert.addTextField { textField in
			textField.placeholder = Preferences.defaultInstallPath
			textField.autocapitalizationType = .none
			textField.addTarget(self, action: #selector(self.textURLDidChange(_:)), for: .editingChanged)
		}

		let setAction = UIAlertAction(title: String.localized("SET"), style: .default) { _ in
			guard let textField = alert.textFields?.first, let enteredURL = textField.text else { return }

			Preferences.onlinePath = enteredURL
		}

		setAction.isEnabled = false
		let cancelAction = UIAlertAction(title: String.localized("CANCEL"), style: .cancel, handler: nil)

		alert.addAction(setAction)
		alert.addAction(cancelAction)
		present(alert, animated: true, completion: nil)
	}


	@objc func textURLDidChange(_ textField: UITextField) {
		guard let alertController = presentedViewController as? UIAlertController, let setAction = alertController.actions.first(where: { $0.title == String.localized("SET") }) else { return }

		let enteredURL = textField.text ?? ""
		setAction.isEnabled = isValidURL(enteredURL)
	}

	func isValidURL(_ url: String) -> Bool {
		let urlPredicate = NSPredicate(format: "SELF MATCHES %@", "https://.+")
		return urlPredicate.evaluate(with: url)
	}
}

extension SettingsViewController {
	func showChangeIdentifierAlert() {
		let alert = UIAlertController(title: String.localized("SETTINGS_VIEW_CONTROLLER_CELL_CHANGE_IDENTIFIER"), message: nil, preferredStyle: .alert)

		alert.addTextField { textField in
			textField.placeholder = Preferences.pPQCheckString
			textField.autocapitalizationType = .none
		}

		let setAction = UIAlertAction(title: String.localized("SET"), style: .default) { _ in
			guard let textField = alert.textFields?.first, let enteredURL = textField.text else { return }

			if !enteredURL.isEmpty {
				Preferences.pPQCheckString = enteredURL
			}
		}

		setAction.isEnabled = true
		let cancelAction = UIAlertAction(title: String.localized("CANCEL"), style: .cancel, handler: nil)

		alert.addAction(setAction)
		alert.addAction(cancelAction)
		present(alert, animated: true, completion: nil)
	}
}
