//
//  ServerOptionsViewController.swift
//  feather
//
//  Created by samara on 22.10.2024.
//  Copyright (c) 2024 Samara M (khcrysalis)
//

import UIKit

class ServerOptionsViewController: UITableViewController {
	
	var isDownloadingCertifcate = false
	
	var tableData = [
		[
			"Use Server",
			String.localized("SETTINGS_VIEW_CONTROLLER_CELL_USE_CUSTOM_SERVER")
		],
		[
			String.localized("SETTINGS_VIEW_CONTROLLER_CELL_UPDATE_LOCAL_CERTIFICATE")
		],
	]
	
	var sectionTitles = 
	[
		"Online",
		"Local",
	]
	
	init() { super.init(style: .insetGrouped) }
	required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
	
	override func viewDidLoad() {
		super.viewDidLoad()
		title = "Server Options"
		self.navigationItem.largeTitleDisplayMode = .never
		updateCells()
	}
}

extension ServerOptionsViewController {
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
		switch section {
		case 0: return String.localized("SETTINGS_VIEW_CONTROLLER_SECTION_FOOTER_DEFAULT_SERVER", arguments: Preferences.defaultInstallPath)
		case 1: return String.localized("SETTINGS_VIEW_CONTROLLER_SECTION_FOOTER_SERVER_LIMITATIONS")
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
				cell.selectionStyle = .default
			}
		case String.localized("SETTINGS_VIEW_CONTROLLER_CELL_RESET_CONFIGURATION"):
			cell.textLabel?.textColor = .systemRed
			cell.textLabel?.textAlignment = .center
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

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let itemTapped = tableData[indexPath.section][indexPath.row]
		switch itemTapped {
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
		default:
			break
		}
		
		tableView.deselectRow(at: indexPath, animated: true)
	}
	
	@objc func onlinePathToggled(_ sender: UISwitch) {
		Preferences.userSelectedServer = sender.isOn
		
		let alertController = UIAlertController(
			title: "",
			message: String.localized("SUCCESS_REQUIRES_RESTART"),
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
	
	private func updateCells() {
		if Preferences.onlinePath != Preferences.defaultInstallPath {
			tableData[0].insert(String.localized("SETTINGS_VIEW_CONTROLLER_CELL_RESET_CONFIGURATION"), at: 2)
		}
		Preferences.installPathChangedCallback = { [weak self] newInstallPath in
			self?.handleInstallPathChange(newInstallPath)
		}
	}
	
	private func handleInstallPathChange(_ newInstallPath: String?) {
		if newInstallPath != Preferences.defaultInstallPath {
			tableData[0].insert(String.localized("SETTINGS_VIEW_CONTROLLER_CELL_RESET_CONFIGURATION"), at: 2)
		} else {
			if let index = tableData[0].firstIndex(of: String.localized("SETTINGS_VIEW_CONTROLLER_CELL_RESET_CONFIGURATION")) {
				tableData[0].remove(at: index)
			}
		}

		tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
	}
}

extension ServerOptionsViewController {
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
