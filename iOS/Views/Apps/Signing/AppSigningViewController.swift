//
//  AppSigningViewController.swift
//  feather
//
//  Created by HAHALOSAH on 7/11/24.
//  Copyright (c) 2024 Samara M (khcrysalis)
//

import Foundation
import UIKit
import CoreData
import UniformTypeIdentifiers

class AppSigningViewController: UITableViewController, UINavigationControllerDelegate {
    var appsViewController: LibraryViewController
	var largeButton = ActivityIndicatorButton()
	var iconCell = IconImageViewCell()

    var toInject: [URL] = []
	var removeInjectPaths: [String] = []
	
    var app: NSManagedObject!
    var name: String = "Unknown"
    var bundleId: String = "unknown"
    var version: String = "unknown"
    var signing = false
	var icon: UIImage?
	
    var uuid = "unknown"
	
	var forceMinimumVersion = 0
	var forceMinimumVersionString = ["Automatic", "15.0", "14.0", "13.0"]
	
	var forceLightDarkAppearance = 0
	var forceLightDarkAppearanceString = ["Automatic", "Light", "Dark"]
    
    var removePlugins = false
    var forceFileSharing = true
    var removeSupportedDevices = true
    var removeURLScheme = false
	var forceProMotion = false
	var forceForceFullScreen = false
	var forceiTunesFileSharing = true
	
	var removeWatchPlaceHolder = true 
	var removeProvisioningFile = false
	
	var certs: Certificate?
    
    init(app: NSManagedObject, appsViewController: LibraryViewController) {
        self.appsViewController = appsViewController
        self.app = app
        super.init(style: .insetGrouped)
		
		if let hasGotCert = CoreDataManager.shared.getCurrentCertificate() {
			self.certs = hasGotCert
		}
        
        if let name = app.value(forKey: "name") as? String {
            self.name = name
        }
        
        if let bundleId = app.value(forKey: "bundleidentifier") as? String {
			if self.certs?.certData?.pPQCheck == true && Preferences.isFuckingPPqcheckDetectionOff == true {
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
		let logoImageView = UIImageView(image: UIImage(named: "feather_glyph"))
		logoImageView.contentMode = .scaleAspectFit
		navigationItem.titleView = logoImageView
		self.navigationController?.navigationBar.prefersLargeTitles = false
        tableView.register(TweakLibraryViewCell.self, forCellReuseIdentifier: "TweakLibraryViewCell")
        tableView.register(SwitchViewCell.self, forCellReuseIdentifier: "SwitchViewCell")
        tableView.register(ActivityIndicatorViewCell.self, forCellReuseIdentifier: "ActivityIndicatorViewCell")
		self.isModalInPresentation = true
		self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: String.localized("DISMISS"), style: .done, target: self, action: #selector(closeSheet))
		setupToolbar()
		
		if (certs == nil) {
			#if !targetEnvironment(simulator)
			DispatchQueue.main.async {
                let alert = UIAlertController(
					title: String.localized("APP_SIGNING_VIEW_CONTROLLER_NO_CERTS_ALERT_TITLE"),
					message: String.localized("APP_SIGNING_VIEW_CONTROLLER_NO_CERTS_ALERT_DESCRIPTION"),
                    preferredStyle: .alert
                )
				alert.addAction(UIAlertAction(title: String.localized("LAME"), style: .default) { _ in
						self.dismiss(animated: true)
					}
				)
				self.present(alert, animated: true, completion: nil)
			}
			#endif
		}
	}
	
	private func setupToolbar() {
		largeButton.addTarget(self, action: #selector(startSign), for: .touchUpInside)
		let largeButtonItem = UIBarButtonItem(customView: largeButton)
		toolbarItems = [ largeButtonItem, ]
		navigationController?.setToolbarHidden(false, animated: false)
	}
	
	@objc func startSign() {
		self.navigationItem.leftBarButtonItem = nil
		signing = true
		largeButton.showLoadingIndicator()
		signInitialApp(options: AppSigningOptions(
			name: name,
			version: version,
			bundleId: bundleId,
			iconURL: icon ?? nil,
			uuid: uuid,
			toInject: toInject,
			removeInjectPaths: removeInjectPaths,
			removePlugins: removePlugins,
			forceFileSharing: forceFileSharing,
			removeSupportedDevices: removeSupportedDevices,
			removeURLScheme: removeURLScheme,
			forceProMotion: forceProMotion,
			forceForceFullScreen: forceForceFullScreen,
			forceiTunesFileSharing: forceiTunesFileSharing,
			forceMinimumVersion: forceMinimumVersionString[forceMinimumVersion],
			forceLightDarkAppearance: forceLightDarkAppearanceString[forceLightDarkAppearance],
			removeProvisioningFile: removeProvisioningFile, removeWatchPlaceHolder: removeWatchPlaceHolder,
			certificate: certs),
				appPath:getFilesForDownloadedApps(app: app as! DownloadedApps, getuuidonly: false)
		) { success in
			if success {
				self.appsViewController.fetchSources()
				self.appsViewController.tableView.reloadData()
			}
			self.dismiss(animated: true)
		}
	}
	
	@objc func closeSheet() {
		dismiss(animated: true, completion: nil)
	}
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 5;
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch(section) {
        case 0:
            return 4;
        case 1:
            return 1;
        case 2:
			return 2;
        case 3:
            return 1;
        default:
            return 0;
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

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
			let cell = iconCell
			
			if (icon != nil) {
				cell.configure(with: icon)
			} else {
				cell.configure(with: CoreDataManager.shared.loadImage(from: getIconURL(for: app as! DownloadedApps)))
			}
			
			cell.accessoryType = .disclosureIndicator
			return cell
        case (0, 1):
			cell.textLabel?.text = String.localized("APPS_INFORMATION_TITLE_NAME")
            cell.detailTextLabel?.text = name
            cell.accessoryType = .disclosureIndicator
        case (0, 2):
			cell.textLabel?.text = String.localized("APPS_INFORMATION_TITLE_IDENTIFIER")
            cell.detailTextLabel?.text = bundleId
            cell.accessoryType = .disclosureIndicator
        case (0, 3):
			cell.textLabel?.text = String.localized("APPS_INFORMATION_TITLE_VERSION")
            cell.detailTextLabel?.text = version
            cell.accessoryType = .disclosureIndicator
		case (1, 0):
			if let hasGotCert = certs {
				let cell = CertificateViewTableViewCell()
				cell.configure(with: hasGotCert, isSelected: false)
				cell.selectionStyle = .none
				return cell
			} else {
				cell.textLabel?.text = String.localized("SETTINGS_VIEW_CONTROLLER_CELL_CURRENT_CERTIFICATE_NOSELECTED")
				cell.textLabel?.textColor = .secondaryLabel
				cell.selectionStyle = .none
			}
            break
        case (2, 0):
			cell.textLabel?.text = String.localized("APP_SIGNING_VIEW_CONTROLLER_CELL_ADD_TWEAKS")
			let badgeView = BadgeView(frame: CGRect(x: 0, y: 0, width: 60, height: 20))
			cell.accessoryView = badgeView

            break
		case (2, 1):
			cell.textLabel?.text = "Remove dylibs"
			let badgeView = BadgeView(frame: CGRect(x: 0, y: 0, width: 60, height: 20))
			cell.accessoryView = badgeView
			break
        case (3, 0):
			cell.textLabel?.text = String.localized("APP_SIGNING_VIEW_CONTROLLER_CELL_ADVANCED")
            cell.accessoryType = .disclosureIndicator
            break
        default:
            break
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch (indexPath.section, indexPath.item) {
		case (0, 0):
			importAppIconFile()
			tableView.deselectRow(at: indexPath, animated: true)
		case (0, 1):
			navigationController?.pushViewController(AppSigningInputViewController(appSigningViewController: self, initialValue: self.name, valueToSaveTo: "name", indexPath: indexPath), animated: true)
		case (0, 2):
			navigationController?.pushViewController(AppSigningInputViewController(appSigningViewController: self, initialValue: self.bundleId, valueToSaveTo: "bundleId", indexPath: indexPath), animated: true)
		case (0, 3):
			navigationController?.pushViewController(AppSigningInputViewController(appSigningViewController: self, initialValue: self.version, valueToSaveTo: "version", indexPath: indexPath), animated: true)
		case (2, 0):
			navigationController?.pushViewController(AppSigningTweakViewController(appSigningViewController: self), animated: true)
		case (2, 1):
			navigationController?.pushViewController(AppSigningDylibViewController(appSigningViewController: self, app: getFilesForDownloadedApps(app: app as! DownloadedApps, getuuidonly: false)), animated: true)
        case (3, 0):
            navigationController?.pushViewController(AppSigningAdvancedViewController(appSigningViewController: self), animated: true)
        default:
            break
        }
    }
	
	override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return [
			40,
			40,
			40,
			0,
			0
		][section]
	}
	
	override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		
		let titles = [
			"Customization",
			"Signing",
			"Advanced",
			"",
			""
		][section]
		
		let headerView = InsetGroupedSectionHeader(title: titles)
		return headerView
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
			Debug.shared.log(message: "Invalid property name: \(propertyName)")
		}
		self.tableView.reloadRows(at: [indexPath], with: .automatic)
	}
	
	func getFilesForDownloadedApps(app: DownloadedApps, getuuidonly: Bool) -> URL {
		return CoreDataManager.shared.getFilesForDownloadedApps(for: app, getuuidonly: getuuidonly)
	}
	
	func getIconURL(for app: DownloadedApps) -> URL? {
		guard let iconURLString = app.value(forKey: "iconURL") as? String,
			  let iconURL = URL(string: iconURLString) else {
			return nil
		}
		
		let filesURL = getFilesForDownloadedApps(app: app, getuuidonly: false)
		return filesURL.appendingPathComponent(iconURL.lastPathComponent)
	}
}
// MARK: - UIDocumentPickerDelegate
extension AppSigningViewController: UIDocumentPickerDelegate & UIImagePickerControllerDelegate {
	func importAppIconFile() {
		let actionSheet = UIAlertController(title: "Select App Icon", message: nil, preferredStyle: .actionSheet)
		
		let documentPickerAction = UIAlertAction(title: "Choose from Files", style: .default) { [weak self] _ in
			self?.presentDocumentPicker(fileExtension: [UTType.image])
		}
		
		let photoLibraryAction = UIAlertAction(title: "Choose from Photos", style: .default) { [weak self] _ in
			self?.presentPhotoLibrary(mediaTypes: ["public.image"])
		}
		
		let cancelAction = UIAlertAction(title: String.localized("CANCEL"), style: .cancel, handler: nil)
		
		actionSheet.addAction(documentPickerAction)
		actionSheet.addAction(photoLibraryAction)
		actionSheet.addAction(cancelAction)
		
		if let popoverController = actionSheet.popoverPresentationController {
			popoverController.sourceView = self.view
			popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
			popoverController.permittedArrowDirections = []
		}
		
		self.present(actionSheet, animated: true, completion: nil)
	}

	// MARK: - Documents
	
	func presentDocumentPicker(fileExtension: [UTType]) {
		let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: fileExtension, asCopy: true)
		documentPicker.delegate = self
		documentPicker.allowsMultipleSelection = false
		present(documentPicker, animated: true, completion: nil)
	}
	
	func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
		guard let selectedFileURL = urls.first else { return }
		let meow = CoreDataManager.shared.loadImage(from: selectedFileURL)
		icon = meow?.resizeToSquare()
		Debug.shared.log(message: "\(selectedFileURL)")
		self.tableView.reloadData()
	}
	
	func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
		controller.dismiss(animated: true, completion: nil)
	}
	
	// MARK: - Library
	
	func presentPhotoLibrary(mediaTypes: [String]) {
		let imagePicker = UIImagePickerController()
		imagePicker.delegate = self
		imagePicker.sourceType = .photoLibrary
		imagePicker.mediaTypes = mediaTypes
		self.present(imagePicker, animated: true, completion: nil)
	}
	
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
		picker.dismiss(animated: true, completion: nil)
		
		guard let selectedImage = info[.originalImage] as? UIImage else { return }
		
		icon = selectedImage.resizeToSquare()
		self.tableView.reloadData()
	}
	
	func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		picker.dismiss(animated: true, completion: nil)
	}


	

}
