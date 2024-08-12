//
//  SettingsViewController.swift
//  feather
//
//  Created by samara on 7/7/24.
//

import UIKit
import Nuke
import SwiftUI

class SettingsViewController: UITableViewController {
	var tableData =
	[
		["Donate"],
		["About Feather", "Submit Feedback", "GitHub Repository"],
		["Display", "App Icon"],
		["Current Certificate", "Add Certificate"],
		["Signing Configuration"],
		["Fuck PPQCheck", "Use Server"],
		["Use Custom Server"],
		["Debug Logs", "Reset"]
	]
	
	var sectionTitles =
	[
		"",
		"",
		"General",
		"Signing",
		"",
		"",
		"",
		"Advanced"
	]
	
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
			return "If any issues occur within Feather please report it via the GitHub repository. When submitting an issue, be sure to submit any logs."
		case 5:
			return "Using a signing server will disable the built-in server Feather uses to retrieve the manifest for itms services, use this in case of the local server failing."
		case 6:
			return "Default server goes to \"\(Preferences.defaultInstallPath)\""
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
		case "About Feather":
			cell.setAccessoryIcon(with: "info.circle")
			cell.selectionStyle = .default
		case "Display":
			cell.setAccessoryIcon(with: "paintbrush")
			cell.selectionStyle = .default
		case "Submit Feedback", "GitHub Repository":
			cell.textLabel?.textColor = .tintColor
			cell.setAccessoryIcon(with: "safari")
			cell.selectionStyle = .default
		case "Reset":
			cell.textLabel?.textColor = .tintColor
			cell.accessoryType = .disclosureIndicator
			cell.selectionStyle = .default
		case "Add Certificate":
			cell.setAccessoryIcon(with: "plus")
			cell.selectionStyle = .default
		case "Current Certificate":
			if let hasGotCert = CoreDataManager.shared.getCurrentCertificate() {
				let cell = CertificateViewTableViewCell()
				cell.configure(with: hasGotCert, isSelected: false)
				cell.selectionStyle = .none
				return cell
			} else {
				cell.textLabel?.text = "No certificates selected"
				cell.textLabel?.textColor = .secondaryLabel
				cell.selectionStyle = .none
			}
		case "Fuck PPQCheck":
			let fuckPPq = SwitchViewCell()
			fuckPPq.textLabel?.text = "Disable PPQCheck Protections"
			fuckPPq.switchControl.addTarget(self, action: #selector(fuckPpqcheckToggled(_:)), for: .valueChanged)
			fuckPPq.switchControl.isOn = Preferences.isFuckingPPqcheckDetectionOff
			fuckPPq.selectionStyle = .none
			return fuckPPq
		case "Use Server":
			let useS = SwitchViewCell()
			useS.textLabel?.text = "Online Install Method"
			useS.switchControl.addTarget(self, action: #selector(onlinePathToggled(_:)), for: .valueChanged)
			useS.switchControl.isOn = Preferences.userSelectedServer
			useS.selectionStyle = .none
			return useS
		case "Use Custom Server":
			if Preferences.onlinePath != Preferences.defaultInstallPath {
				cell.textLabel?.textColor = UIColor.systemGray
				cell.isUserInteractionEnabled = false
				cell.textLabel?.text = Preferences.onlinePath!
			} else {
				cell.textLabel?.textColor = .tintColor
			}
		case "Reset Configuration":
			cell.textLabel?.textColor = .systemRed
			cell.textLabel?.textAlignment = .center
		case "App Icon":
			cell.setAccessoryIcon(with: "app.dashed")
			cell.selectionStyle = .default
		default:
			break
		}
		
		return cell
	}
	
	@objc func onlinePathToggled(_ sender: UISwitch) {
		Preferences.userSelectedServer = sender.isOn
	}
	
	@objc func fuckPpqcheckToggled(_ sender: UISwitch) {
		Preferences.isFuckingPPqcheckDetectionOff = sender.isOn
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let itemTapped = tableData[indexPath.section][indexPath.row]
		switch itemTapped {
		case "Display":
			let l = DisplayViewController()
			navigationController?.pushViewController(l, animated: true)
		case "About Feather":
			let l = AboutViewController()
			navigationController?.pushViewController(l, animated: true)
		case "Reset":
			let l = ResetViewController()
			navigationController?.pushViewController(l, animated: true)
		case "Add Certificate":
			let l = CertificatesViewController()
			navigationController?.pushViewController(l, animated: true)
		case "App Icon":
			let iconsListViewController = IconsListViewController()
			navigationController?.pushViewController(iconsListViewController, animated: true)
		case "Use Custom Server":
			showChangeDownloadURLAlert()
		case "Reset Configuration":
			resetConfigDefault()
		default:
			break
		}
		
		tableView.deselectRow(at: indexPath, animated: true)
	}
	
	func updateCells() {
		if Preferences.onlinePath != Preferences.defaultInstallPath {
			tableData[6].insert("Reset Configuration", at: 1)
		}
		Preferences.installPathChangedCallback = { [weak self] newInstallPath in
			self?.handleInstallPathChange(newInstallPath)
		}
	}
	
	private func handleInstallPathChange(_ newInstallPath: String?) {
		if newInstallPath != Preferences.defaultInstallPath {
			tableData[6].insert("Reset Configuration", at: 1)
		} else {
			if let index = tableData[6].firstIndex(of: "Reset Configuration") {
				tableData[6].remove(at: index)
			}
		}

		tableView.reloadSections(IndexSet(integer: 6), with: .automatic)
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
		let alert = UIAlertController(title: "Change Download URL", message: nil, preferredStyle: .alert)

		alert.addTextField { textField in
			textField.placeholder = Preferences.defaultInstallPath
			textField.autocapitalizationType = .none
			textField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
		}

		let setAction = UIAlertAction(title: "Set", style: .default) { _ in
			guard let textField = alert.textFields?.first, let enteredURL = textField.text else { return }

			Preferences.onlinePath = enteredURL
		}

		setAction.isEnabled = false
		let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

		alert.addAction(setAction)
		alert.addAction(cancelAction)
		present(alert, animated: true, completion: nil)
	}


	@objc func textFieldDidChange(_ textField: UITextField) {
		guard let alertController = presentedViewController as? UIAlertController, let setAction = alertController.actions.first(where: { $0.title == "Set" }) else { return }

		let enteredURL = textField.text ?? ""
		setAction.isEnabled = isValidURL(enteredURL)
	}

	func isValidURL(_ url: String) -> Bool {
		let urlPredicate = NSPredicate(format: "SELF MATCHES %@", "https?://$")
		return urlPredicate.evaluate(with: url)
	}
}
