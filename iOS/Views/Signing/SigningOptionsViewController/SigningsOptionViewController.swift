//
//  SigningsOptionViewController.swift
//  feather
//
//  Created by samara on 26.10.2024.
//

import CoreData
import UIKit

struct TogglesOption {
	let title: String
	let footer: String?
	var binding: Bool
}

func toggleOptions(signingDataWrapper: SigningDataWrapper) -> [TogglesOption] {
	return [
		TogglesOption(
			title: String.localized("APP_SIGNING_INPUT_VIEW_CONTROLLER_REMOVE_PLUGINS"),
			footer: String.localized("APP_SIGNING_INPUT_VIEW_CONTROLLER_REMOVE_PLUGINS_DESCRIPTION"),
			binding: signingDataWrapper.signingOptions.removePlugins
		   ),
		   TogglesOption(
			title: String.localized("APP_SIGNING_INPUT_VIEW_CONTROLLER_REMOVE_ALLOW_BROWSING_DOCUMENTS"),
			footer: String.localized("APP_SIGNING_INPUT_VIEW_CONTROLLER_REMOVE_ALLOW_BROWSING_DOCUMENTS_DESCRIPTION"),
			binding: signingDataWrapper.signingOptions.forceFileSharing
		   ),
		   TogglesOption(
			title: String.localized("APP_SIGNING_INPUT_VIEW_CONTROLLER_REMOVE_UISUPPORTEDDEVICES"),
			footer: String.localized("APP_SIGNING_INPUT_VIEW_CONTROLLER_REMOVE_UISUPPORTEDDEVICES_DESCRIPTION"),
			binding: signingDataWrapper.signingOptions.removeSupportedDevices
		   ),
		   TogglesOption(
			title: String.localized("APP_SIGNING_INPUT_VIEW_CONTROLLER_REMOVE_URLSCHEME"),
			footer: String.localized("APP_SIGNING_INPUT_VIEW_CONTROLLER_REMOVE_URLSCHEME_DESCRIPTION"),
			binding: signingDataWrapper.signingOptions.removeURLScheme
		   ),
		   TogglesOption(
			title: String.localized("APP_SIGNING_INPUT_VIEW_CONTROLLER_FORCE_PRO_MOTION"),
			footer: String.localized("APP_SIGNING_INPUT_VIEW_CONTROLLER_FORCE_PRO_MOTION_DESCRIPTION"),
			binding: signingDataWrapper.signingOptions.forceProMotion
		   ),
		   TogglesOption(
			title: String.localized("APP_SIGNING_INPUT_VIEW_CONTROLLER_REMOVE_FORCE_FULLSCREEN"),
			footer: String.localized("APP_SIGNING_INPUT_VIEW_CONTROLLER_REMOVE_FORCE_FULLSCREEN_DESCRIPTION"),
				binding: signingDataWrapper.signingOptions.forceForceFullScreen
		   ),
		   TogglesOption(
			title: String.localized("APP_SIGNING_INPUT_VIEW_CONTROLLER_REMOVE_ALLOW_ITUNES_SHARING"),
			footer: String.localized("APP_SIGNING_INPUT_VIEW_CONTROLLER_REMOVE_ALLOW_ITUNES_SHARING_DESCRIPTION"),
			binding: signingDataWrapper.signingOptions.forceiTunesFileSharing
		   ),
		   TogglesOption(
			title: String.localized("APP_SIGNING_INPUT_VIEW_CONTROLLER_FORCELOCALIZATIONS"),
			footer: String.localized("APP_SIGNING_INPUT_VIEW_CONTROLLER_FORCELOCALIZATIONS_DESCRIPTION"),
			binding: signingDataWrapper.signingOptions.forceTryToLocalize
		   ),
		   TogglesOption(
			title: String.localized("APP_SIGNING_INPUT_VIEW_CONTROLLER_REMOVE_PROVISIONING"),
			footer: String.localized("APP_SIGNING_INPUT_VIEW_CONTROLLER_REMOVE_PROVISIONING_DESCRIPTION"),
			binding: signingDataWrapper.signingOptions.removeProvisioningFile
		   ),
		   TogglesOption(
			title: String.localized("APP_SIGNING_INPUT_VIEW_CONTROLLER_REMOVE_DELETE_PLACEHOLDER_WATCH_APP"),
			footer: String.localized("APP_SIGNING_INPUT_VIEW_CONTROLLER_REMOVE_DELETE_PLACEHOLDER_WATCH_APP_DESCRIPTION"),
			binding: signingDataWrapper.signingOptions.removeWatchPlaceHolder
		   )
	   ]
}

class SigningsOptionViewController: UITableViewController {

	private var application: NSManagedObject?
	private var appsViewController: LibraryViewController?
	var signingDataWrapper: SigningDataWrapper
	
	private var toggleOptions: [TogglesOption]
	
	init(signingDataWrapper: SigningDataWrapper, application: NSManagedObject? = nil, appsViewController: LibraryViewController? = nil) {
		self.signingDataWrapper = signingDataWrapper
		self.application = application
		self.appsViewController = appsViewController
		self.toggleOptions = feather.toggleOptions(signingDataWrapper: signingDataWrapper)
		super.init(style: .insetGrouped)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupViews()
		setupNavigation()
	}
	
	fileprivate func setupViews() {
		tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
	}

	fileprivate func setupNavigation() {
		self.navigationItem.largeTitleDisplayMode = .never
		self.title = String.localized("APP_SIGNING_VIEW_CONTROLLER_CELL_SIGNING_OPTIONS_TITLE")
		self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(save))
	}
	
	@objc func save() {
		UserDefaults.standard.signingOptions = signingDataWrapper.signingOptions
		self.navigationController?.popViewController(animated: true)
	}
}

extension SigningsOptionViewController {
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 2 + toggleOptions.count
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch section {
		case 0:  return 2
		case 1:  return 3
		default: return 1
		}
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell(style: .default, reuseIdentifier: "cell")
		cell.textLabel?.textColor = .label
		cell.accessoryView = nil
		
		switch [indexPath.section, indexPath.row] {
		case [0,0]:
			cell.textLabel?.text = String.localized("SETTINGS_VIEW_CONTROLLER_CELL_CHANGE_ID")
			cell.textLabel?.textColor = .tintColor
			cell.selectionStyle = .default
		case [0,1]:
			cell.textLabel?.text = String.localized("SETTINGS_VIEW_CONTROLLER_CELL_EXPORT_ID")
			cell.textLabel?.textColor = .tintColor
			cell.selectionStyle = .default
		case [1,0]:
			let toggleSwitch = UISwitch()
			cell.textLabel?.text = String.localized("APP_SIGNING_VIEW_CONTROLLER_CELL_SIGNING_OPTIONS_PROTECTIONS")
			toggleSwitch.isOn = signingDataWrapper.signingOptions.ppqCheckProtection
			toggleSwitch.tag = 0
			toggleSwitch.addTarget(self, action: #selector(toggleOptionsSwitches(_:)), for: .valueChanged)
			cell.accessoryView = toggleSwitch
		case [1,1]:
			cell.textLabel?.text = String.localized("APP_SIGNING_VIEW_CONTROLLER_CELL_SIGNING_OPTIONS_IDENTIFIERS")
			cell.accessoryType = .disclosureIndicator
		case [1,2]:
			let toggleSwitch = UISwitch()
			cell.textLabel?.text = String.localized("APP_SIGNING_VIEW_CONTROLLER_CELL_SIGNING_OPTIONS_INSTALLAFTERSIGNED")
			toggleSwitch.isOn = signingDataWrapper.signingOptions.installAfterSigned
			toggleSwitch.tag = 1
			toggleSwitch.addTarget(self, action: #selector(toggleOptionsSwitches(_:)), for: .valueChanged)
			cell.accessoryView = toggleSwitch
		default:
			let toggleOption = toggleOptions[indexPath.section - 2]
			cell.textLabel?.text = toggleOption.title
			
			let toggleSwitch = UISwitch()
			toggleSwitch.isOn = toggleOption.binding
			toggleSwitch.tag = indexPath.section + 2
			toggleSwitch.addTarget(self, action: #selector(toggleOptionsSwitches(_:)), for: .valueChanged)
			cell.accessoryView = toggleSwitch
		}
		
		return cell
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		
		switch [indexPath.section, indexPath.row] {
		case [0, 0]:
			showChangeIdentifierAlert()
		case [0, 1]:
			let shareText = Preferences.pPQCheckString
			let activityViewController = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
			
			if let popoverController = activityViewController.popoverPresentationController {
				popoverController.sourceView = self.view
				popoverController.sourceRect = self.view.bounds
				popoverController.permittedArrowDirections = []
			}
			
			present(activityViewController, animated: true, completion: nil)
		case [1, 1]:
			let l = IdentifiersViewController(signingDataWrapper: signingDataWrapper)
			navigationController?.pushViewController(l, animated: true)
		default:
			break
		}
		
	}
	
	@objc func toggleOptionsSwitches(_ sender: UISwitch) {
		switch sender.tag {
		case 0:
			signingDataWrapper.signingOptions.ppqCheckProtection = sender.isOn
		case 1:
			signingDataWrapper.signingOptions.installAfterSigned = sender.isOn
		case 2:
			signingDataWrapper.signingOptions.removePlugins = sender.isOn
		case 3:
			signingDataWrapper.signingOptions.forceFileSharing = sender.isOn
		case 4:
			signingDataWrapper.signingOptions.removeSupportedDevices = sender.isOn
		case 5:
			signingDataWrapper.signingOptions.removeURLScheme = sender.isOn
		case 6:
			signingDataWrapper.signingOptions.forceProMotion = sender.isOn
		case 7:
			signingDataWrapper.signingOptions.forceForceFullScreen = sender.isOn
		case 8:
			signingDataWrapper.signingOptions.forceiTunesFileSharing = sender.isOn
		case 9:
			signingDataWrapper.signingOptions.forceTryToLocalize = sender.isOn
		case 10:
			signingDataWrapper.signingOptions.removeProvisioningFile = sender.isOn
		case 11:
			signingDataWrapper.signingOptions.removeWatchPlaceHolder = sender.isOn
		default:
			break
		}
	}
	
	override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		if section == 1 {
			return String.localized("APP_SIGNING_VIEW_CONTROLLER_CELL_SIGNING_OPTIONS_PROTECTIONS_DESCRIPTION")
		} else {
			let toggleIndex = section - 2
			if toggleIndex >= 0 && toggleIndex < toggleOptions.count {
				let toggleOption = toggleOptions[toggleIndex]
				return toggleOption.footer
			}
		}
		return nil // Return nil if section is out of bounds
	}

}

extension SigningsOptionViewController {
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
