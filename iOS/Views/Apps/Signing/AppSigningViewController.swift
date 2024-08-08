//
//  AppSigningViewController.swift
//  feather
//
//  Created by HAHALOSAH on 7/11/24.
//

import Foundation
import UIKit
import CoreData

class AppSigningViewController: UITableViewController {
    var appsViewController: DownloadedAppsViewController

    var toInject: [String] = []
    var app: NSManagedObject!
    var name: String = "Unknown"
    var bundleId: String = "unknown"
    var version: String = "unknown"
    var signing = false
	
    var uuid = "unknown"
	
	var injectionTool = 1
	var injectionToolString = ["Substrate", "Substitute", "Ellekit"]
	
	var forceMinimumVersion = 0
	var forceMinimumVersionString = ["Automatic", "15.0", "14.0", "13.0"]
	
	var forceLightDarkAppearence = 0
	var forceLightDarkAppearenceString = ["Automatic", "Light", "Dark"]
    
    var removePlugins = false
    var forceFileSharing = true
    var removeSupportedDevices = true
    var removeURLScheme = false
	var forceProMotion = false
	var forceForceFullScreen = false
	var forceiTunesFileSharing = true
	
	var certs: Certificate?
    
    init(app: NSManagedObject, appsViewController: DownloadedAppsViewController) {
        self.appsViewController = appsViewController
        
        self.app = app
		self.certs = CoreDataManager.shared.getCurrentCertificate()
		
		if (self.certs == nil) {
			Debug.shared.log(message: "AppSigningViewController.init", type: .error)
		}
		
        super.init(style: .insetGrouped)
        
        if let name = app.value(forKey: "name") as? String {
            self.name = name
        }
        
        if let bundleId = app.value(forKey: "bundleidentifier") as? String {
			if ((self.certs?.certData?.pPQCheck) != nil) {
				self.bundleId = bundleId+"."+Preferences.pPQCheckString
			} else {
				self.bundleId = bundleId
			}
        }
        
        if let version = app.value(forKey: "version") as? String {
            self.version = version
        }
        
        if let uuid = app.value(forKey: "uuid") as? String {
            self.uuid = uuid
        }
    }
	
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
		self.title = "Sign App"
		
        tableView.register(TweakLibraryViewCell.self, forCellReuseIdentifier: "TweakLibraryViewCell")
        tableView.register(SwitchViewCell.self, forCellReuseIdentifier: "SwitchViewCell")
        tableView.register(ActivityIndicatorViewCell.self, forCellReuseIdentifier: "ActivityIndicatorViewCell")
		self.isModalInPresentation = true
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 5;
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch(section) {
        case 0:
            return 3;
        case 1:
            return 1;
        case 2:
            return 2 + toInject.count;
        case 3:
            return 1;
        case 4:
            return 1;
        default:
            return 0;
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.section == 2) {
            if (indexPath.item == 0) {
				let cell = tableView.dequeueReusableCell(withIdentifier: "TweakLibraryViewCell", for: indexPath) as! TweakLibraryViewCell
				cell.configureSegmentedControl(
					with: injectionToolString,
					selectedIndex: injectionTool
				)
				cell.segmentedControl.addTarget(self, action: #selector(injectionToolDidChange(_:)), for: .valueChanged)
				cell.selectionStyle = .none
				return cell
            }
        }
        if (indexPath.section == 4) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ActivityIndicatorViewCell", for: indexPath) as! ActivityIndicatorViewCell
            cell.textLabel?.text = "Sign"
            cell.textLabel?.textColor = signing ? .systemGray : .systemBlue
            if signing {
                cell.activityIndicator.startAnimating()
                cell.activityIndicator.isHidden = false
            } else {
                cell.activityIndicator.isHidden = true
                cell.activityIndicator.stopAnimating()
            }
            return cell
        }
        /*if (indexPath.section == 3) {
            if (indexPath.row == 0) {
                let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchViewCell", for: indexPath) as! SwitchViewCell
                cell.textLabel?.text = "Remove all PlugIns"
                cell.switchControl.isOn = removePlugins
                cell.switchControl.addTarget(self, action: #selector(removePluginsToggled(_:)), for: .valueChanged)
                return cell
            }
        }*/
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "Cell")
        cell.accessoryType = .none
        cell.selectionStyle = .none
        cell.textLabel?.textColor = .label
        cell.selectionStyle = .gray
        
        switch (indexPath.section, indexPath.item) {
        case (0, 0):
            cell.textLabel?.text = "Name"
            cell.detailTextLabel?.text = name
            cell.accessoryType = .disclosureIndicator
        case (0, 1):
            cell.textLabel?.text = "Bundle ID"
            cell.detailTextLabel?.text = bundleId
            cell.accessoryType = .disclosureIndicator
        case (0, 2):
            cell.textLabel?.text = "Version"
            cell.detailTextLabel?.text = version
            cell.accessoryType = .disclosureIndicator
        case (1, 0):
            cell.textLabel?.text = "Entitlements"
            cell.detailTextLabel?.text = ""
            cell.accessoryType = .disclosureIndicator
            break
        case (2, toInject.count + 1):
            cell.textLabel?.text = "Add a deb/dylib..."
            cell.textLabel?.textColor = .systemBlue
            break
        case (3, 0):
            cell.textLabel?.text = "Advanced"
            cell.accessoryType = .disclosureIndicator
            break
        default:
            break
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // tableView.deselectRow(at: indexPath, animated: true)
        switch (indexPath.section, indexPath.item) {
		case (0, 0):
			navigationController?.pushViewController(AppSigningInputViewController(appSigningViewController: self, initialValue: self.name, valueToSaveTo: "name", indexPath: indexPath), animated: true)
		case (0, 1):
			navigationController?.pushViewController(AppSigningInputViewController(appSigningViewController: self, initialValue: self.bundleId, valueToSaveTo: "bundleId", indexPath: indexPath), animated: true)
		case (0, 2):
			navigationController?.pushViewController(AppSigningInputViewController(appSigningViewController: self, initialValue: self.version, valueToSaveTo: "version", indexPath: indexPath), animated: true)
        case (3, 0):
            navigationController?.pushViewController(AppSigningAdvancedViewController(appSigningViewController: self), animated: true)
        case (4, 0):
            self.navigationItem.setHidesBackButton(true, animated: true)
            signing = true
            tableView.reloadRows(at: [indexPath], with: .none)
            signApp(options: AppSigningOptions(
				name: name,
				version: version,
				bundleId: bundleId,
				uuid: uuid, 
				injectionTool: injectionToolString[injectionTool],
				removePlugins: removePlugins,
				forceFileSharing: forceFileSharing,
				removeSupportedDevices: removeSupportedDevices,
				removeURLScheme: removeURLScheme,
				forceProMotion: forceProMotion,
				forceForceFullScreen: forceForceFullScreen,
				forceiTunesFileSharing: forceiTunesFileSharing,
				forceMinimumVersion: forceMinimumVersionString[forceMinimumVersion],
				forceLightDarkAppearence: forceLightDarkAppearenceString[forceLightDarkAppearence],
				certificate: certs)
			) { success in
				self.dismiss(animated: true)
                self.appsViewController.fetchSources()
                self.appsViewController.tableView.reloadData()
            }
        default:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return [
            "Customization",
            "Signing",
            "Tweak Injection",
            nil,
            nil
        ][section]
    }
	
	@objc private func injectionToolDidChange(_ sender: UISegmentedControl) {
		injectionTool = sender.selectedSegmentIndex
	}
	
	func updateValue(propertyName: String, value: String?, indexPath: IndexPath) {
		switch propertyName {
		case "name":
			name = value ?? "Unknown"
		case "bundleId":
			bundleId = value ?? "unknown"
		case "version":
			version = value ?? "unknown"
		default:
			print("Invalid property name: \(propertyName)")
		}
		self.tableView.reloadRows(at: [indexPath], with: .automatic)
	}

}

class AppSigningInputViewController: UITableViewController {
	var appSigningViewController: AppSigningViewController
	var initialValue: String!
	var valueToSaveTo: String!
	var indexPath: IndexPath!
	private var changedValue: String?
	
	private lazy var textField: UITextField = {
		let textField = UITextField(frame: .zero)
		textField.translatesAutoresizingMaskIntoConstraints = false
		textField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
		return textField
	}()

	init(appSigningViewController: AppSigningViewController, initialValue: String, valueToSaveTo: String, indexPath: IndexPath) {
		self.appSigningViewController = appSigningViewController
		self.initialValue = initialValue
		self.valueToSaveTo = valueToSaveTo
		self.indexPath = indexPath
		super.init(style: .insetGrouped)
	}
	
	required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
	
	override func viewDidLoad() {
		super.viewDidLoad()
		navigationItem.largeTitleDisplayMode = .never
		self.title = valueToSaveTo.capitalized
		
		let saveButton = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(saveButton))
		saveButton.isEnabled = false
		navigationItem.rightBarButtonItem = saveButton
		
		tableView.register(UITableViewCell.self, forCellReuseIdentifier: "InputCell")
	}
	
	@objc func saveButton() {
		appSigningViewController.updateValue(propertyName: valueToSaveTo, value: changedValue, indexPath: indexPath)
		self.navigationController?.popViewController(animated: true)
	}
	
	@objc private func textDidChange() {
		navigationItem.rightBarButtonItem?.isEnabled = !(textField.text?.isEmpty ?? true)
		changedValue = textField.text
	}
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		if ((appSigningViewController.certs?.certData?.pPQCheck) != nil) && valueToSaveTo == "bundleId"{
			return 3
		} else {
			return 1
		}
	}
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return 1 }
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		var cell = tableView.dequeueReusableCell(withIdentifier: "InputCell", for: indexPath)
		switch indexPath.section {
		case 0:
			textField.text = initialValue
			textField.placeholder = initialValue
	
			if textField.superview == nil {
				cell.contentView.addSubview(textField)
				NSLayoutConstraint.activate([
					textField.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
					textField.leadingAnchor.constraint(equalTo: cell.contentView.layoutMarginsGuide.leadingAnchor),
					textField.trailingAnchor.constraint(equalTo: cell.contentView.layoutMarginsGuide.trailingAnchor)
				])
			}
			
			cell.selectionStyle = .none
		case 1:
			cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
			
			cell.textLabel?.text = "PPQCheck is Enabled"
			cell.textLabel?.textColor = .systemRed
			
			cell.detailTextLabel?.text = "Sadly your certificate seems to have the PPQCheck option enabled and cannot be turned off by any normal means, so we've appended a random string to your Bundle Identifier. If you wish to continue you may remove that prepended string or disable it in settings."
			cell.detailTextLabel?.textColor = .systemOrange
			cell.textLabel?.numberOfLines = 0
			cell.detailTextLabel?.numberOfLines = 0
		case 2:
			cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
			
			cell.textLabel?.text = "Information"
			cell.textLabel?.textColor = .label
			
			cell.detailTextLabel?.text = "PPQCheck is a way for Apple to check if the app you're opening matches another bundle identifier found on the App Store, the check happens every time you open the signed installed application. By default we prepended the random string to save you from a headache of getting the Apple ID associated with the certificate locked."
			cell.detailTextLabel?.textColor = .secondaryLabel
			cell.textLabel?.numberOfLines = 0
			cell.detailTextLabel?.numberOfLines = 0
		default: break
		}
		return cell
	}
}

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
    
    override func viewDidLoad() {
        title = "Advanced"
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
        removePluginsCell.textLabel?.text = "Remove all PlugIns"
        removePluginsCell.switchControl.addTarget(self, action: #selector(removePluginsToggled(_:)), for: .valueChanged)
        removePluginsCell.switchControl.isOn = appSigningViewController.removePlugins
        removePluginsCell.selectionStyle = .none
        cellsForSection2.append(removePluginsCell)
        
        let removeSupportedDevicesCell = SwitchViewCell()
        removeSupportedDevicesCell.textLabel?.text = "Remove UISupportedDevices"
        removeSupportedDevicesCell.switchControl.addTarget(self, action: #selector(removeSupportedDevicesToggled(_:)), for: .valueChanged)
        removeSupportedDevicesCell.switchControl.isOn = appSigningViewController.removeSupportedDevices
        removeSupportedDevicesCell.selectionStyle = .none
        cellsForSection2.append(removeSupportedDevicesCell)
        
        let removeURLSchemeCell = SwitchViewCell()
        removeURLSchemeCell.textLabel?.text = "Remove URLScheme"
        removeURLSchemeCell.switchControl.addTarget(self, action: #selector(removeURLSchemeToggled(_:)), for: .valueChanged)
        removeURLSchemeCell.switchControl.isOn = appSigningViewController.removeURLScheme
        removeURLSchemeCell.selectionStyle = .none
        cellsForSection2.append(removeURLSchemeCell)
		
		let forceFileSharingCell = SwitchViewCell()
		forceFileSharingCell.textLabel?.text = "Allow browsing Documents"
		forceFileSharingCell.switchControl.addTarget(self, action: #selector(forceFileSharingToggled(_:)), for: .valueChanged)
		forceFileSharingCell.switchControl.isOn = appSigningViewController.forceFileSharing
		forceFileSharingCell.selectionStyle = .none
		cellsForSection2.append(forceFileSharingCell)
		
		let forceiTunesFileSharing = SwitchViewCell()
		forceiTunesFileSharing.textLabel?.text = "Allow iTunes Sharing"
		forceiTunesFileSharing.switchControl.addTarget(self, action: #selector(forceiTunesFileSharingToggled(_:)), for: .valueChanged)
		forceiTunesFileSharing.switchControl.isOn = appSigningViewController.forceiTunesFileSharing
		forceiTunesFileSharing.selectionStyle = .none
		cellsForSection2.append(forceiTunesFileSharing)
		
		let forceProMotion = SwitchViewCell()
		forceProMotion.textLabel?.text = "Force Pro Motion"
		forceProMotion.switchControl.addTarget(self, action: #selector(forceFileSharingToggled(_:)), for: .valueChanged)
		forceProMotion.switchControl.isOn = appSigningViewController.forceProMotion
		forceProMotion.selectionStyle = .none
		cellsForSection2.append(forceProMotion)
		
		let forceForceFullScreen = SwitchViewCell()
		forceForceFullScreen.textLabel?.text = "Force Fullscreen"
		forceForceFullScreen.switchControl.addTarget(self, action: #selector(forceForceFullScreenToggled(_:)), for: .valueChanged)
		forceForceFullScreen.switchControl.isOn = appSigningViewController.forceForceFullScreen
		forceForceFullScreen.selectionStyle = .none
		cellsForSection2.append(forceForceFullScreen)
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		switch section {
		case 0: return "Appearence"
		case 1: return "Minimum App Version"
		case 2: return "Plist Properties"
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
}
