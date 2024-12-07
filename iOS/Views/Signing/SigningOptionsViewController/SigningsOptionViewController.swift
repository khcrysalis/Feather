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
			title: String.localized("APP_SIGNING_INPUT_VIEW_CONTROLLER_REMOVE_FORCE_PRO_MOTION"),
			footer: String.localized("APP_SIGNING_INPUT_VIEW_CONTROLLER_REMOVE_FORCE_PRO_MOTION_DESCRIPTION"),
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
		   ),
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
	}
	
	@objc func toggleOptionsSwitches(_ sender: UISwitch) {
		Debug.shared.log(message: "Toggle switch tag: \(sender.tag)")
		
		switch sender.tag {
		case 0:  // PPQ Protection
			signingDataWrapper.signingOptions.ppqCheckProtection = sender.isOn
			Debug.shared.log(message: "PPQ Protection set to: \(sender.isOn)")
			if !sender.isOn {
				signingDataWrapper.signingOptions.dynamicProtection = false
				if let dynamicCell = tableView.cellForRow(at: IndexPath(row: 1, section: 1)),
				   let dynamicSwitch = dynamicCell.accessoryView as? UISwitch {
					dynamicSwitch.isEnabled = false
					dynamicSwitch.isOn = false
				}
			} else {
				if let dynamicCell = tableView.cellForRow(at: IndexPath(row: 1, section: 1)),
				   let dynamicSwitch = dynamicCell.accessoryView as? UISwitch {
					dynamicSwitch.isEnabled = true
				}
			}
		case 1:  // Install after signed
			signingDataWrapper.signingOptions.installAfterSigned = sender.isOn
			Debug.shared.log(message: "Install after signed set to: \(sender.isOn)")
		case 2:  // Immediately install from source
			signingDataWrapper.signingOptions.immediatelyInstallFromSource = sender.isOn
			Debug.shared.log(message: "Immediately install from source set to: \(sender.isOn)")
		case 3:  // Dynamic protection
			signingDataWrapper.signingOptions.dynamicProtection = sender.isOn
			Debug.shared.log(message: "Dynamic protection set to: \(sender.isOn)")
		case 4:  // Remove plugins 
			signingDataWrapper.signingOptions.removePlugins = sender.isOn
			Debug.shared.log(message: "Remove plugins (tag 4) set to: \(sender.isOn)")
		case 5:  // Force file sharing 
			signingDataWrapper.signingOptions.forceFileSharing = sender.isOn
			Debug.shared.log(message: "Force file sharing (tag 5) set to: \(sender.isOn)")
		case 6:  // Remove supported devices 
			signingDataWrapper.signingOptions.removeSupportedDevices = sender.isOn
			Debug.shared.log(message: "Remove supported devices (tag 6) set to: \(sender.isOn)")
		case 7:  // Remove URL scheme 
			signingDataWrapper.signingOptions.removeURLScheme = sender.isOn
			Debug.shared.log(message: "Remove URL scheme (tag 7) set to: \(sender.isOn)")
		case 8:  // Force ProMotion 
			signingDataWrapper.signingOptions.forceProMotion = sender.isOn
			Debug.shared.log(message: "Force ProMotion (tag 8) set to: \(sender.isOn)")
		case 9:  // Force fullscreen 
			signingDataWrapper.signingOptions.forceForceFullScreen = sender.isOn
			Debug.shared.log(message: "Force fullscreen (tag 9) set to: \(sender.isOn)")
		case 10:  // Force iTunes file sharing
			signingDataWrapper.signingOptions.forceiTunesFileSharing = sender.isOn
			Debug.shared.log(message: "Force iTunes file sharing (tag 10) set to: \(sender.isOn)")
		case 11:  // Force try to localize 
			signingDataWrapper.signingOptions.forceTryToLocalize = sender.isOn
			Debug.shared.log(message: "Force try to localize (tag 11) set to: \(sender.isOn)")
		case 12:  // Remove provisioning file 
			signingDataWrapper.signingOptions.removeProvisioningFile = sender.isOn
			Debug.shared.log(message: "Remove provisioning file (tag 12) set to: \(sender.isOn)")
		case 13:  // Remove watch placeholder 
			signingDataWrapper.signingOptions.removeWatchPlaceHolder = sender.isOn
			Debug.shared.log(message: "Remove watch placeholder (tag 13) set to: \(sender.isOn)")
		default:
			break
		}
		
		UserDefaults.standard.signingOptions = signingDataWrapper.signingOptions
	}
}

extension SigningsOptionViewController {
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 2 + toggleOptions.count
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch section {
		case 0:  return 2
		case 1:  return 6
		default: return 1
		}
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell(style: .default, reuseIdentifier: "cell")
		cell.textLabel?.textColor = .label
		cell.accessoryView = nil
		
		Debug.shared.log(message: "Setting up cell at section: \(indexPath.section), row: \(indexPath.row)")
		
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
			Debug.shared.log(message: "Setting PPQ protection switch tag: 0")
			toggleSwitch.addTarget(self, action: #selector(toggleOptionsSwitches(_:)), for: .valueChanged)
			cell.accessoryView = toggleSwitch
			cell.selectionStyle = .none
		case [1,1]:
			let toggleSwitch = UISwitch()
			cell.textLabel?.text = String.localized("APP_SIGNING_VIEW_CONTROLLER_CELL_SIGNING_OPTIONS_DYNAMIC_PROTECTION")
			toggleSwitch.isOn = signingDataWrapper.signingOptions.dynamicProtection
			toggleSwitch.isEnabled = signingDataWrapper.signingOptions.ppqCheckProtection
			toggleSwitch.tag = 3
			Debug.shared.log(message: "Setting dynamic protection switch tag: 3")
			toggleSwitch.addTarget(self, action: #selector(toggleOptionsSwitches(_:)), for: .valueChanged)
			cell.accessoryView = toggleSwitch
			cell.selectionStyle = .none
		case [1,2]:
			cell.textLabel?.text = String.localized("APP_SIGNING_VIEW_CONTROLLER_CELL_SIGNING_OPTIONS_IDENTIFIERS")
			cell.accessoryType = .disclosureIndicator
		case [1,3]:
			cell.textLabel?.text = String.localized("APP_SIGNING_VIEW_CONTROLLER_CELL_SIGNING_OPTIONS_DISPLAYNAMES")
			cell.accessoryType = .disclosureIndicator
		case [1,4]:
			let toggleSwitch = UISwitch()
			cell.textLabel?.text = String.localized("APP_SIGNING_VIEW_CONTROLLER_CELL_SIGNING_OPTIONS_INSTALLAFTERSIGNED")
			toggleSwitch.isOn = signingDataWrapper.signingOptions.installAfterSigned
			toggleSwitch.tag = 1
			Debug.shared.log(message: "Setting install after signed switch tag: 1")
			toggleSwitch.addTarget(self, action: #selector(toggleOptionsSwitches(_:)), for: .valueChanged)
			cell.accessoryView = toggleSwitch
		case [1,5]:
			let toggleSwitch = UISwitch()
			cell.textLabel?.text = String.localized("APP_SIGNING_VIEW_CONTROLLER_CELL_SIGNING_OPTIONS_IMMEDIATELY_INSTALL_FROM_SOURCE")
			toggleSwitch.isOn = signingDataWrapper.signingOptions.immediatelyInstallFromSource
			toggleSwitch.tag = 2
			Debug.shared.log(message: "Setting immediately install switch tag: 2")
			toggleSwitch.addTarget(self, action: #selector(toggleOptionsSwitches(_:)), for: .valueChanged)
			cell.accessoryView = toggleSwitch
			cell.selectionStyle = .none
		default:
			let toggleIndex = indexPath.section - 2
			if toggleIndex >= 0 && toggleIndex < toggleOptions.count {
				let toggleOption = toggleOptions[toggleIndex]
				cell.textLabel?.text = toggleOption.title
				
				let toggleSwitch = UISwitch()
				toggleSwitch.isOn = toggleOption.binding
				toggleSwitch.tag = toggleIndex + 4  // Start at 4 for the first toggle option
				Debug.shared.log(message: "Setting toggle option switch tag: \(toggleSwitch.tag) for option: \(toggleOption.title) at index: \(toggleIndex)")
				toggleSwitch.addTarget(self, action: #selector(toggleOptionsSwitches(_:)), for: .valueChanged)
				cell.accessoryView = toggleSwitch
				cell.selectionStyle = .none
			}
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
		case [1, 2]:
			let l = IdentifiersViewController(signingDataWrapper: signingDataWrapper, mode: .bundleId)
				navigationController?.pushViewController(l, animated: true)
		case [1, 3]:
			let l = IdentifiersViewController(signingDataWrapper: signingDataWrapper, mode: .displayName)
				navigationController?.pushViewController(l, animated: true)
		default:
			break
		}
		
	}
	
	override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		if section == 1 {
			let protectionDescription = String.localized("APP_SIGNING_VIEW_CONTROLLER_CELL_SIGNING_OPTIONS_PROTECTIONS_DESCRIPTION")
			let dynamicDescription = String.localized("APP_SIGNING_VIEW_CONTROLLER_CELL_SIGNING_OPTIONS_DYNAMIC_PROTECTION_DESCRIPTION")
			return protectionDescription + "\n\n" + dynamicDescription
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
