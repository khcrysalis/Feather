//
//  AppSigningAdvancedViewController.swift
//  feather
//
//  Created by samara on 8/15/24.
//  Copyright (c) 2024 Samara M (khcrysalis)
//

import Foundation
import UIKit
// MARK: - AppSigningAdvancedViewController
class AppSigningAdvancedViewController: UITableViewController {
	var cellsForSection0 = [UITableViewCell]()
	var cellsForSection1 = [UITableViewCell]()
	var cellsForSection2 = [UITableViewCell]()
	var appSigningViewController: AppSigningViewController
	
	init(appSigningViewController: AppSigningViewController) {
		self.appSigningViewController = appSigningViewController
		super.init(style: .insetGrouped)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		navigationController?.setToolbarHidden(true, animated: animated)
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		navigationController?.setToolbarHidden(false, animated: animated)
	}
	
	override func viewDidLoad() {
		title = String.localized("APP_SIGNING_VIEW_CONTROLLER_CELL_ADVANCED")
		navigationItem.largeTitleDisplayMode = .never
		
		let forceLightDarkAppearence = TweakLibraryViewCell()
		forceLightDarkAppearence.selectionStyle = .none
		forceLightDarkAppearence.configureSegmentedControl(
			with: appSigningViewController.forceLightDarkAppearenceString,
			selectedIndex: appSigningViewController.forceLightDarkAppearence
		)
		forceLightDarkAppearence.segmentedControl.addTarget(self, action: #selector(forceLightDarkAppearenceDidChange(_:)), for: .valueChanged)
		cellsForSection0.append(forceLightDarkAppearence)
		
		let forceMinimumVersion = TweakLibraryViewCell()
		forceMinimumVersion.selectionStyle = .none
		forceMinimumVersion.configureSegmentedControl(
			with: appSigningViewController.forceMinimumVersionString,
			selectedIndex: appSigningViewController.forceMinimumVersion
		)
		forceMinimumVersion.segmentedControl.addTarget(self, action: #selector(forceMinimumVersionDidChange(_:)), for: .valueChanged)
		cellsForSection1.append(forceMinimumVersion)
		
		let removePluginsCell = SwitchViewCell()
		removePluginsCell.textLabel?.text = String.localized("APP_SIGNING_INPUT_VIEW_CONTROLLER_REMOVE_PLUGINS")
		removePluginsCell.switchControl.addTarget(self, action: #selector(removePluginsToggled(_:)), for: .valueChanged)
		removePluginsCell.switchControl.isOn = appSigningViewController.removePlugins
		removePluginsCell.selectionStyle = .none
		cellsForSection2.append(removePluginsCell)
		
		let removeSupportedDevicesCell = SwitchViewCell()
		removeSupportedDevicesCell.textLabel?.text = String.localized("APP_SIGNING_INPUT_VIEW_CONTROLLER_REMOVE_UISUPPORTEDDEVICES")
		removeSupportedDevicesCell.switchControl.addTarget(self, action: #selector(removeSupportedDevicesToggled(_:)), for: .valueChanged)
		removeSupportedDevicesCell.switchControl.isOn = appSigningViewController.removeSupportedDevices
		removeSupportedDevicesCell.selectionStyle = .none
		cellsForSection2.append(removeSupportedDevicesCell)
		
		let removeURLSchemeCell = SwitchViewCell()
		removeURLSchemeCell.textLabel?.text = String.localized("APP_SIGNING_INPUT_VIEW_CONTROLLER_REMOVE_URLSCHEME")
		removeURLSchemeCell.switchControl.addTarget(self, action: #selector(removeURLSchemeToggled(_:)), for: .valueChanged)
		removeURLSchemeCell.switchControl.isOn = appSigningViewController.removeURLScheme
		removeURLSchemeCell.selectionStyle = .none
		cellsForSection2.append(removeURLSchemeCell)
		
		let forceFileSharingCell = SwitchViewCell()
		forceFileSharingCell.textLabel?.text = String.localized("APP_SIGNING_INPUT_VIEW_CONTROLLER_REMOVE_ALLOW_BROWSING_DOCUMENTS")
		forceFileSharingCell.switchControl.addTarget(self, action: #selector(forceFileSharingToggled(_:)), for: .valueChanged)
		forceFileSharingCell.switchControl.isOn = appSigningViewController.forceFileSharing
		forceFileSharingCell.selectionStyle = .none
		cellsForSection2.append(forceFileSharingCell)
		
		let forceiTunesFileSharing = SwitchViewCell()
		forceiTunesFileSharing.textLabel?.text = String.localized("APP_SIGNING_INPUT_VIEW_CONTROLLER_REMOVE_ALLOW_ITUNES_SHARING")
		forceiTunesFileSharing.switchControl.addTarget(self, action: #selector(forceiTunesFileSharingToggled(_:)), for: .valueChanged)
		forceiTunesFileSharing.switchControl.isOn = appSigningViewController.forceiTunesFileSharing
		forceiTunesFileSharing.selectionStyle = .none
		cellsForSection2.append(forceiTunesFileSharing)
		
		let forceProMotion = SwitchViewCell()
		forceProMotion.textLabel?.text = String.localized("APP_SIGNING_INPUT_VIEW_CONTROLLER_REMOVE_FORCE_PRO_MOTION")
		forceProMotion.switchControl.addTarget(self, action: #selector(forceFileSharingToggled(_:)), for: .valueChanged)
		forceProMotion.switchControl.isOn = appSigningViewController.forceProMotion
		forceProMotion.selectionStyle = .none
		cellsForSection2.append(forceProMotion)
		
		let forceForceFullScreen = SwitchViewCell()
		forceForceFullScreen.textLabel?.text = String.localized("APP_SIGNING_INPUT_VIEW_CONTROLLER_REMOVE_FORCE_FULLSCREEN")
		forceForceFullScreen.switchControl.addTarget(self, action: #selector(forceForceFullScreenToggled(_:)), for: .valueChanged)
		forceForceFullScreen.switchControl.isOn = appSigningViewController.forceForceFullScreen
		forceForceFullScreen.selectionStyle = .none
		cellsForSection2.append(forceForceFullScreen)
		
		let removeWatchPlaceHolder = SwitchViewCell()
		removeWatchPlaceHolder.textLabel?.text = String.localized("APP_SIGNING_INPUT_VIEW_CONTROLLER_REMOVE_DELETE_PLACEHOLDER_WATCH_APP")
		removeWatchPlaceHolder.switchControl.addTarget(self, action: #selector(removePlaceHolderWatchExtension(_:)), for: .valueChanged)
		removeWatchPlaceHolder.switchControl.isOn = appSigningViewController.removeWatchPlaceHolder
		removeWatchPlaceHolder.selectionStyle = .none
		cellsForSection2.append(removeWatchPlaceHolder)
		
		let removeProvisioningFile = SwitchViewCell()
		removeProvisioningFile.textLabel?.text = "Include Provisioning File"
		removeProvisioningFile.switchControl.addTarget(self, action: #selector(removeProvisioningFile(_:)), for: .valueChanged)
		removeProvisioningFile.switchControl.isOn = appSigningViewController.removeProvisioningFile
		removeProvisioningFile.selectionStyle = .none
		cellsForSection2.append(removeProvisioningFile)
	}
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 3
	}
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		switch section {
		case 0: return String.localized("APP_SIGNING_INPUT_VIEW_CONTROLLER_SECTION_TITLE_APPEARENCE")
		case 1: return String.localized("APP_SIGNING_INPUT_VIEW_CONTROLLER_SECTION_TITLE_MINIMUM_APP_VERSION")
		case 2: return String.localized("APP_SIGNING_INPUT_VIEW_CONTROLLER_SECTION_TITLE_PROPERTIES")
		default: return nil
		}
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch section {
		case 0: return cellsForSection0.count
		case 1: return cellsForSection1.count
		case 2: return cellsForSection2.count
		default: return 0
		}
	}
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		switch indexPath.section {
		case 0: return cellsForSection0[indexPath.item]
		case 1: return cellsForSection1[indexPath.item]
		case 2: return cellsForSection2[indexPath.item]
		default: return UITableViewCell()
		}
	}
	
	@objc private func removePluginsToggled(_ sender: UISwitch) {
		appSigningViewController.removePlugins = sender.isOn
	}
	@objc private func forceFileSharingToggled(_ sender: UISwitch) {
		appSigningViewController.forceFileSharing = sender.isOn
	}
	@objc private func removeSupportedDevicesToggled(_ sender: UISwitch) {
		appSigningViewController.removeSupportedDevices = sender.isOn
	}
	@objc private func removeURLSchemeToggled(_ sender: UISwitch) {
		appSigningViewController.removeURLScheme = sender.isOn
	}
	@objc private func forceProMotionToggled(_ sender: UISwitch) {
		appSigningViewController.forceProMotion = sender.isOn
	}
	@objc private func forceForceFullScreenToggled(_ sender: UISwitch) {
		appSigningViewController.forceForceFullScreen = sender.isOn
	}
	@objc private func forceiTunesFileSharingToggled(_ sender: UISwitch) {
		appSigningViewController.forceiTunesFileSharing = sender.isOn
	}
	@objc private func forceLightDarkAppearenceDidChange(_ sender: UISegmentedControl) {
		appSigningViewController.forceLightDarkAppearence = sender.selectedSegmentIndex
	}
	@objc private func forceMinimumVersionDidChange(_ sender: UISegmentedControl) {
		appSigningViewController.forceMinimumVersion = sender.selectedSegmentIndex
	}
	@objc private func removePlaceHolderWatchExtension(_ sender: UISwitch) {
		appSigningViewController.removeWatchPlaceHolder = sender.isOn
	}
	@objc private func removeProvisioningFile(_ sender: UISwitch) {
		appSigningViewController.removeProvisioningFile = sender.isOn
	}
}
