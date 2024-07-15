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
	
	let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
	
	lazy var saveButton = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveAction))
	private var passwordTextField: UITextField?
	
	enum FileType: Hashable {
		case provision
		case p12
		case certPEM
		case certDER
		case keyPEM
		case keyDER
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
		
		if let fileContent = readMobileProvisionFile(atPath: mobileProvisionPath.path) {
			if let plistContent = extractPlist(fromMobileProvision: fileContent) {
				if let plistData = plistContent.data(using: .utf8) {
					do {
						let decoder = PropertyListDecoder()
						let cert = try decoder.decode(Cert.self, from: plistData)
						self.addToCD(cert: cert, files: selectedFiles)
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
		var cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
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
			cell.detailTextLabel?.text = ".p12, .pem"
			
			if (selectedFiles[.p12] != nil) || (selectedFiles[.certPEM] != nil) {
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
		case "key":
			cell.textLabel?.text = "Import Private Key File"
			cell.detailTextLabel?.text = ".pem"
			fileType = .keyPEM
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
			return "Import a file containing a valid certificate, using just a pem (not p12) will prompt you to import the private key that belongs to that file."
		case "key":
			return "Import your private key that belongs to your certificate."
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
		case "key":
			fileType = .keyPEM
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
			presentDocumentPicker(fileExtension: [UTType(filenameExtension: "p12")!, UTType(filenameExtension: "pem")!, UTType(filenameExtension: "der")!])
		case "key":
			presentDocumentPicker(fileExtension: [UTType(filenameExtension: "pem")!, UTType(filenameExtension: "der")!])
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
		case "pem":
			if (selectedFiles[.certPEM] == nil) && (selectedFiles[.p12] == nil) && checkIfFileIsCert(cert: selectedFileURL) {
				fileType = .certPEM
				sectionData.insert("key", at: 2)
			} else if (selectedFiles[.certPEM] != nil) && (selectedFiles[.p12] != nil) && !checkIfFileIsCert(cert: selectedFileURL) {
				fileType = .keyPEM
			} else {
				fileType = nil
			}
		case "der":
			fileType = nil
		default:
			fileType = nil
		}
		
		if let fileType = fileType {
			selectedFiles[fileType] = selectedFileURL
			tableView.reloadData()
		}
		
		if (selectedFiles[.provision] != nil) && (selectedFiles[.certPEM] != nil) && (selectedFiles[.keyPEM] != nil) {
			saveButton.isEnabled = true
		} else if (selectedFiles[.provision] != nil) && (selectedFiles[.p12] != nil) {
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

extension CertImportingVC {
	func addToCD(cert: Cert, files: [FileType: Any] = [:]) {
		print(cert)
		print(files)
		// jaisdsabxdyfsadxy7sufadxtysfaxdasrydxr236x47328xn
		let provisionPath = (selectedFiles[.provision] as! URL)
		let p12Path = (selectedFiles[.p12] as? URL)
		let keyPath = (selectedFiles[.keyPEM] as? URL)
		let certPath = (selectedFiles[.certPEM] as? URL)
		let uuid = UUID().uuidString
		
		let context = self.context
		
		let newC = Certificate(context: context)
		
		newC.uuid = uuid
		
		newC.p12Path = p12Path?.lastPathComponent ?? nil
		newC.provisionPath = provisionPath.lastPathComponent
		newC.certPath = certPath?.lastPathComponent ?? nil
		newC.dateAdded = Date()
		newC.keyPath = keyPath?.lastPathComponent ?? nil
		newC.password = files[.password] as? String ?? nil
		
		let certData = CertificateData(context: context)
		newC.certData = certData
		
		certData.appIDName = cert.AppIDName
		certData.creationDate = cert.CreationDate
		certData.expirationDate = cert.ExpirationDate
		certData.isXcodeManaged = cert.IsXcodeManaged
		certData.name = cert.Name
		certData.pPQCheck = cert.PPQCheck ?? false
		certData.teamName = cert.TeamName
		certData.uuid = cert.UUID
		certData.version = Int32(cert.Version)
		
		let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
		let p = documentsDirectory
			.appendingPathComponent("Certificates")
			.appendingPathComponent(uuid)
		

		do {
			try! FileManager.default.createDirectory(at: p, withIntermediateDirectories: true, attributes: nil)
			
			func copyFile(from sourceURL: URL?, to destinationDirectory: URL) throws {
				guard let sourceURL = sourceURL else { return }
				let destinationURL = destinationDirectory.appendingPathComponent(sourceURL.lastPathComponent)
				try FileManager.default.copyItem(at: sourceURL, to: destinationURL)
			}

			try copyFile(from: provisionPath, to: p)
			try copyFile(from: p12Path, to: p)
			try copyFile(from: keyPath, to: p)
			try copyFile(from: certPath, to: p)
		} catch {
			print("Error copying files: \(error)")
		}
	
		
		do {
			try context.save()
			NotificationCenter.default.post(name: Notification.Name("t"), object: nil)
			dismiss(animated: true, completion: nil)
		} catch {
			print("error saving context: \(error)")
		}
	}


	func readMobileProvisionFile(atPath path: String) -> String? {
		do {
			let fileContent = try String(contentsOfFile: path, encoding: .ascii)
			
			if fileContent.contains("<?xml") && fileContent.contains("<plist") && fileContent.contains("<dict>") && fileContent.contains("TimeToLive") {
				return fileContent
			} else {
				print("File does not appear to be a valid mobile provisioning file?")
				return nil
			}
		} catch {
			print("Error reading file: \(error)")
			return nil
		}
	}

	func extractPlist(fromMobileProvision fileContent: String) -> String? {
		guard let startRange = fileContent.range(of: "<?xml"),
			  let endRange = fileContent.range(of: "</plist>") else {
			return nil
		}
		
		let plistContent = fileContent[startRange.lowerBound..<endRange.upperBound]
		return String(plistContent)
	}
}
