//
//  SigningOptionsViewController.swift
//  feather
//
//  Created by samara on 22.10.2024.
//  Copyright (c) 2024 Samara M (khcrysalis)
//

import UIKit

class SigningOptionsViewController: UITableViewController {
	
	var tableData =
	[
		[
			"Auto Install",
			"Fuck PPQCheck",
		],
		[
			"PPQCheckMitigationString",
			"PPQCheckMitigationExport"
		],
		[],
	]
	
	var sectionTitles =
	[
		"Options",
		"",
		"Signing Default Config",
	]
	
	init() { super.init(style: .insetGrouped) }
	required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupNavigation()
	}
	
	fileprivate func setupNavigation() {
		self.title = String.localized("Signing Options")
		self.navigationItem.largeTitleDisplayMode = .never
	}
}

extension SigningOptionsViewController {
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
//		case "Auto Install":
//			let autoInstall = SwitchViewCell()
//			autoInstall.textLabel?.text = "Install after signing"
//			autoInstall.switchControl.addTarget(self, action: #selector(autoInstallAfterSignToggled(_:)), for: .valueChanged)
//			autoInstall.switchControl.isOn = Preferences.autoInstallAfterSign
//			autoInstall.selectionStyle = .none
//			return autoInstall
//		case "Fuck PPQCheck":
//			let fuckPPq = SwitchViewCell()
//			fuckPPq.textLabel?.text = String.localized("SETTINGS_VIEW_CONTROLLER_PPQ_ALERT_TITLE")
//			fuckPPq.switchControl.addTarget(self, action: #selector(fuckPpqcheckToggled(_:)), for: .valueChanged)
//			fuckPPq.switchControl.isOn = Preferences.isFuckingPPqcheckDetectionOff
//			fuckPPq.selectionStyle = .none
//
//			let infoButton = UIButton(type: .infoLight)
//			infoButton.addTarget(self, action: #selector(showPPQInfoAlert), for: .touchUpInside)
//			fuckPPq.accessoryView = infoButton
//
//			return fuckPPq

		case "PPQCheckMitigationString":
			cell.textLabel?.text = String.localized("SETTINGS_VIEW_CONTROLLER_CELL_CHANGE_ID")
			cell.textLabel?.textColor = .tintColor
			cell.selectionStyle = .default
		case "PPQCheckMitigationExport":
			cell.textLabel?.text = String.localized("SETTINGS_VIEW_CONTROLLER_CELL_EXPORT_ID")
			cell.textLabel?.textColor = .tintColor

			cell.selectionStyle = .default
		default:
			break
		}
		
		return cell
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let itemTapped = tableData[indexPath.section][indexPath.row]
		switch itemTapped {
		case "PPQCheckMitigationString":
			showChangeIdentifierAlert()
		case "PPQCheckMitigationExport":
			let shareText = Preferences.pPQCheckString
			let activityViewController = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
			
			if let popoverController = activityViewController.popoverPresentationController {
				popoverController.sourceView = self.view
				popoverController.sourceRect = self.view.bounds
				popoverController.permittedArrowDirections = []
			}
			
			present(activityViewController, animated: true, completion: nil)
		default:
			break
		}
		
		tableView.deselectRow(at: indexPath, animated: true)
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
	
//	@objc func fuckPpqcheckToggled(_ sender: UISwitch) {
//		Preferences.isFuckingPPqcheckDetectionOff = sender.isOn
//	}
//	
//	@objc func autoInstallAfterSignToggled(_ sender: UISwitch) {
//		Preferences.autoInstallAfterSign = sender.isOn
//	}
	
}

extension SigningOptionsViewController {
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
