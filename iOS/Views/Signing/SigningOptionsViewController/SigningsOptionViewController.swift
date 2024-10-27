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
			   title: "Remove all PlugIns",
			   footer: "Removes the PlugIns directory inside of the app, which would usually have some components for the app to function properly.",
			   binding: signingDataWrapper.signingOptions.removePlugins
		   ),
		   TogglesOption(
			   title: "Force File Sharing",
			   footer: "Allows other apps to open and edit the files stored in the Documents folder. This option also lets users set the app’s default save location in Settings.",
			   binding: signingDataWrapper.signingOptions.forceFileSharing
		   ),
		   TogglesOption(
			   title: "Remove UISupportedDevices",
			   footer: "Removes device restrictions for the application.",
			   binding: signingDataWrapper.signingOptions.removeSupportedDevices
		   ),
		   TogglesOption(
			   title: "Remove URL Scheme",
			   footer: "Removes any possible URL schemes (i.e. 'feather://')",
			   binding: signingDataWrapper.signingOptions.removeURLScheme
		   ),
		   TogglesOption(
			   title: "Enable ProMotion",
			   footer: "Enables ProMotion capabilities within the app, however on lower versions of 15.x this may not be enough.",
			   binding: signingDataWrapper.signingOptions.forceProMotion
		   ),
		   TogglesOption(
			   title: "Force Full Screen",
			   footer: "Forces only fullscreen capabilities within iPad apps, disallowing sharing the screen with other apps. On an external screen, the window for an app with this setting maintains its canvas size.",
			   binding: signingDataWrapper.signingOptions.forceForceFullScreen
		   ),
		   TogglesOption(
			   title: "Force iTunes File Sharing",
			   footer: "Forces the app to share their documents directory, allowing sharing between iTunes and Finder.",
			   binding: signingDataWrapper.signingOptions.forceiTunesFileSharing
		   ),
		   TogglesOption(
			   title: "Force Try To Localize",
			   footer: "Forces localization by modifying every localizable bundle within the app when trying to change a name of the app.",
			   binding: signingDataWrapper.signingOptions.forceTryToLocalize
		   ),
		   TogglesOption(
			   title: "Remove Provisioning File",
			   footer: "Removes .mobileprovison from appearing in your app after signing.",
			   binding: signingDataWrapper.signingOptions.removeProvisioningFile
		   ),
		   TogglesOption(
			   title: "Remove Watch Placeholder",
			   footer: "Removes unwanted watch placeholder which isn't supposed to be there, present in apps such as YouTube music, etc.",
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
		self.title = "Signing Options"
		self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(save))
	}
	
	@objc func save() {
		UserDefaults.standard.signingOptions = signingDataWrapper.signingOptions
		self.navigationController?.popViewController(animated: true)
	}
}

extension SigningsOptionViewController {
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1 + toggleOptions.count
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return section == 0 ? 3 : 1
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell(style: .default, reuseIdentifier: "cell")
		
		switch [indexPath.section, indexPath.row] {
		case [0,0]:
			let toggleSwitch = UISwitch()
			cell.textLabel?.text = "Enable Protection"
			toggleSwitch.isOn = signingDataWrapper.signingOptions.ppqCheckProtection
			toggleSwitch.tag = 0
			toggleSwitch.addTarget(self, action: #selector(toggleOptionsSwitches(_:)), for: .valueChanged)
			cell.accessoryView = toggleSwitch
		case [0,1]:
			cell.textLabel?.text = "Bundle Identifiers"
			cell.accessoryType = .disclosureIndicator
			cell.accessoryView = nil
		case [0,2]:
			let toggleSwitch = UISwitch()
			cell.textLabel?.text = "Install after Signing"
			toggleSwitch.isOn = signingDataWrapper.signingOptions.installAfterSigned
			toggleSwitch.tag = 1
			toggleSwitch.addTarget(self, action: #selector(toggleOptionsSwitches(_:)), for: .valueChanged)
			cell.accessoryView = toggleSwitch
		default:
			let toggleOption = toggleOptions[indexPath.section - 1]
			cell.textLabel?.text = toggleOption.title
			
			let toggleSwitch = UISwitch()
			toggleSwitch.isOn = toggleOption.binding
			toggleSwitch.tag = indexPath.section + 1
			toggleSwitch.addTarget(self, action: #selector(toggleOptionsSwitches(_:)), for: .valueChanged)
			cell.accessoryView = toggleSwitch
		}
		
		return cell
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		
		switch [indexPath.section, indexPath.row] {
		case [0, 1]:
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
		guard section > 0 else {
			return "Enabling protections will pre-append every bundle identifier with a random string, this is to protect the Apple ID related to your certificate from being flagged by Apple. However, if you don't care about this you can ignore."
		}
		let toggleOption = toggleOptions[section - 1]
		return toggleOption.footer
	}
}
