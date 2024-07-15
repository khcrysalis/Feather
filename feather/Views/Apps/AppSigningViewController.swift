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
    var appsViewController: AppsViewController
    
    var toInject: [String] = []
    var app: NSManagedObject!
    var name = "Unknown"
    var bundleId = "unknown"
    var version = "unknown"
    var signing = false
    var uuid = "unknown"
    
    var removePlugins = false
    var forceFileSharing = false
    var removeSupportedDevices = false
    var removeURLScheme = false
    
    init(app: NSManagedObject, appsViewController: AppsViewController) {
        self.appsViewController = appsViewController
        
        self.app = app
        super.init(style: .insetGrouped)
        
        if let name = app.value(forKey: "name") as? String {
            self.name = name
        }
        
        if let bundleId = app.value(forKey: "bundleidentifier") as? String {
            self.bundleId = bundleId
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
        title = "Sign App"
        tableView.register(TweakLibraryViewCell.self, forCellReuseIdentifier: "TweakLibraryViewCell")
        tableView.register(SwitchViewCell.self, forCellReuseIdentifier: "SwitchViewCell")
        tableView.register(ActivityIndicatorViewCell.self, forCellReuseIdentifier: "ActivityIndicatorViewCell")
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 5;
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch(section) {
        case 0:
            return 3;
        case 1:
            return 2;
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
                cell.segmentedControl.selectedSegmentIndex = 2
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
            cell.textLabel?.text = "Certificate"
            cell.detailTextLabel?.text = "key.p12"
            cell.accessoryType = .disclosureIndicator
            break
        case (1, 1):
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
        case (3, 0):
            navigationController?.pushViewController(AppSigningAdvancedViewController(appSigningViewController: self), animated: true)
        case (4, 0):
            self.navigationItem.setHidesBackButton(true, animated: true)
            signing = true
            tableView.reloadRows(at: [indexPath], with: .none)
            signApp(options: AppSigningOptions(name: name, version: version, bundleId: bundleId, uuid: uuid, removePlugins: removePlugins, forceFileSharing: forceFileSharing, removeSupportedDevices: removeSupportedDevices, removeURLScheme: removeURLScheme, certificate: nil)) { success in
                self.navigationController?.popViewController(animated: true)
                self.appsViewController.segmentedControl.selectedSegmentIndex = 1
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
}

class AppSigningAdvancedViewController: UITableViewController {
    var cells = [UITableViewCell]()
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
        
        let removePluginsCell = SwitchViewCell()
        removePluginsCell.textLabel?.text = "Remove all PlugIns"
        removePluginsCell.switchControl.addTarget(self, action: #selector(removePluginsToggled(_:)), for: .valueChanged)
        removePluginsCell.switchControl.isOn = appSigningViewController.removePlugins
        removePluginsCell.selectionStyle = .none
        cells.append(removePluginsCell)
        
        let forceFileSharingCell = SwitchViewCell()
        forceFileSharingCell.textLabel?.text = "Force allow browsing Documents"
        forceFileSharingCell.switchControl.addTarget(self, action: #selector(forceFileSharingToggled(_:)), for: .valueChanged)
        forceFileSharingCell.switchControl.isOn = appSigningViewController.forceFileSharing
        forceFileSharingCell.selectionStyle = .none
        cells.append(forceFileSharingCell)
        
        let removeSupportedDevicesCell = SwitchViewCell()
        removeSupportedDevicesCell.textLabel?.text = "Remove UISupportedDevices"
        removeSupportedDevicesCell.switchControl.addTarget(self, action: #selector(removeSupportedDevicesToggled(_:)), for: .valueChanged)
        removeSupportedDevicesCell.switchControl.isOn = appSigningViewController.removeSupportedDevices
        removeSupportedDevicesCell.selectionStyle = .none
        cells.append(removeSupportedDevicesCell)
        
        let removeURLSchemeCell = SwitchViewCell()
        removeURLSchemeCell.textLabel?.text = "Remove URLScheme"
        removeURLSchemeCell.switchControl.addTarget(self, action: #selector(removeURLSchemeToggled(_:)), for: .valueChanged)
        removeURLSchemeCell.switchControl.isOn = appSigningViewController.removeURLScheme
        removeURLSchemeCell.selectionStyle = .none
        cells.append(removeURLSchemeCell)
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cells[indexPath.item]
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
}
