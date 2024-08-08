//
//  CertImportingVC.swift
//  feather
//
//  Created by samara on 7/13/24.
//

import Foundation
import UIKit
import UniformTypeIdentifiers

class CertImportingVC: UITableViewController {
		
	lazy var saveButton = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveAction))
	private var passwordTextField: UITextField?
	
	enum FileType: Hashable {
		case provision
		case p12
		case password
	}
	
	var sectionData = [
		"provision",
		"certs",
		"pass"
	]
	
	private var selectedFiles: [FileType: Any] = [:]
	
	init() { super.init(style: .insetGrouped) }
	required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupNavigation()
		setupViews()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
	}
	
	fileprivate func setupViews() {
		self.tableView.dataSource = self
		self.tableView.delegate = self
	}
	
	fileprivate func setupNavigation() {
		self.navigationItem.largeTitleDisplayMode = .never
		self.title = "Import"
		saveButton.isEnabled = false
		self.navigationItem.rightBarButtonItem = saveButton
		self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Dismiss", style: .done, target: self, action: #selector(closeSheet))
	}
	
	@objc func closeSheet() {
		dismiss(animated: true, completion: nil)
	}
	
	@objc func saveAction() {
        
		//krilling myself, also improving code later just not today lmaoo
		
		let mobileProvisionPath: URL!
		mobileProvisionPath = (selectedFiles[.provision] as! URL)
        if let p12path = selectedFiles[.p12] as? URL {
            password_check_fix_WHAT_THE_FUCK(mobileProvisionPath.path)
            if (!p12_password_check(p12path.path, selectedFiles[.password] as? String ?? "")) {
                let alert = UIAlertController(title: "Bad Password", message: "Please check the password and try again.", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
        }
		
		if let fileContent = CertData.readMobileProvisionFile(atPath: mobileProvisionPath.path) {
			if let plistContent = CertData.extractPlist(fromMobileProvision: fileContent) {
				if let plistData = plistContent.data(using: .utf8) {
					do {
						let decoder = PropertyListDecoder()
						let cert = try decoder.decode(Cert.self, from: plistData)
						CoreDataManager.shared.addToCertificates(cert: cert, files: selectedFiles)
						self.dismiss(animated: true)
					} catch {
						print("Error decoding plist data: \(error)")
					}
				} else {
					print("Failed to convert plist content to data")
				}
			} else {
				print("Failed to extract plist content")
			}
		} else {
			print("Failed to read mobileprovision file")
		}
	}
	
	@objc func textFieldDidChange(_ textField: UITextField) {
		guard textField === passwordTextField else { return }
		
		if let password = textField.text {
			selectedFiles[.password] = password
		}
	}
}

extension CertImportingVC {
	override func numberOfSections(in tableView: UITableView) -> Int { return sectionData.count }
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return 1 }
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
		cell.selectionStyle = .default
		
		let imageView = UIImageView(image: UIImage(systemName: "circle"))
		imageView.tintColor = .quaternaryLabel
		cell.accessoryView = imageView
		
		cell.textLabel?.font = .boldSystemFont(ofSize: 15)
		cell.detailTextLabel?.textColor = .secondaryLabel
		
		let fileType: FileType
		
		switch sectionData[indexPath.section] {
		case "provision":
			cell.textLabel?.text = "Import Provisioning File"
			cell.detailTextLabel?.text = ".mobileprovision"
			fileType = .provision
		case "certs":
			cell.textLabel?.text = "Import Certificate File"
			cell.detailTextLabel?.text = ".p12"
			
			if (selectedFiles[.p12] != nil) {
				let checkmarkImage = UIImage(systemName: "checkmark")
				let checkmarkImageView = UIImageView(image: checkmarkImage)
				checkmarkImageView.tintColor = .systemBlue
				cell.accessoryView = checkmarkImageView
			} else {
				let circleImage = UIImage(systemName: "circle")
				let circleImageView = UIImageView(image: circleImage)
				circleImageView.tintColor = .quaternaryLabel
				cell.accessoryView = circleImageView
			}
			
			return cell
		case "pass":
			let passwordCell = UITableViewCell(style: .default, reuseIdentifier: "PasswordCell")
			let textField = UITextField(frame: CGRect(x: 0, y: 0, width: 200, height: 30))
			
			textField.placeholder = "Enter password"
			textField.isSecureTextEntry = true
			textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
			
			passwordCell.textLabel?.text = "Password"
			passwordCell.selectionStyle = .none
			passwordCell.accessoryView = textField
			
			passwordTextField = textField
			
			return passwordCell
		default:
			return cell
		}
		
		if (selectedFiles[fileType] != nil) {
			let checkmarkImage = UIImage(systemName: "checkmark")
			let checkmarkImageView = UIImageView(image: checkmarkImage)
			checkmarkImageView.tintColor = .systemBlue
			cell.accessoryView = checkmarkImageView
		} else {
			let circleImage = UIImage(systemName: "circle")
			let circleImageView = UIImageView(image: circleImage)
			circleImageView.tintColor = .quaternaryLabel
			cell.accessoryView = circleImageView
		}
		
		return cell
	}



	
	override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		switch sectionData[section] {
		case "provision":
			return "Import a provisioning file to be able to sideload to your device."
		case "certs":
			return "Import a file containing a valid certificate."
		case "pass":
			return "Enter the password associated with the private key, leave it blank if theres no password required."
		default:
			return nil
		}
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let fileType: FileType
		
		switch sectionData[indexPath.section] {
		case "provision":
			fileType = .provision
		case "certs":
			fileType = .p12
		default:
			return
		}
		
		guard (selectedFiles[fileType] == nil) else {
			tableView.deselectRow(at: indexPath, animated: true)
			return
		}
		
		switch sectionData[indexPath.section] {
		case "provision":
			presentDocumentPicker(fileExtension: [UTType(filenameExtension: "mobileprovision")!])
		case "certs":
			presentDocumentPicker(fileExtension: [UTType(filenameExtension: "p12")!])
		default:
			return
		}
		
		tableView.deselectRow(at: indexPath, animated: true)
	}

}

extension CertImportingVC: UIDocumentPickerDelegate {
	func presentDocumentPicker(fileExtension: [UTType]) {
		let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: fileExtension, asCopy: true)
		documentPicker.delegate = self
		documentPicker.allowsMultipleSelection = false
		present(documentPicker, animated: true, completion: nil)
	}
	
	func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
		guard let selectedFileURL = urls.first else { return }
				
		let fileType: FileType?
		
		switch selectedFileURL.pathExtension {
		case "mobileprovision":
			fileType = .provision
		case "p12":
			fileType = .p12
		default:
			fileType = nil
		}
		
		if let fileType = fileType {
			selectedFiles[fileType] = selectedFileURL
			tableView.reloadData()
		}
		
		if (selectedFiles[.provision] != nil) && (selectedFiles[.p12] != nil) {
			saveButton.isEnabled = true
		}
	}

	
	func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
		controller.dismiss(animated: true, completion: nil)
	}
	
	func checkIfFileIsCert(cert: URL?) -> Bool {
		guard let cert = cert, cert.isFileURL else { return false }
		
		do {
			let fileContent = try String(contentsOf: cert, encoding: .utf8)
			if fileContent.contains("BEGIN CERTIFICATE") {
				return true
			}
		} catch {
			print("Error reading file: \(error)")
		}
		
		return false
	}
}
