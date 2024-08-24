//
//  AppSigningInputViewController.swift
//  feather
//
//  Created by samara on 8/15/24.
//  Copyright (c) 2024 Samara M (khcrysalis)
//

import Foundation 
import UIKit
// MARK: - AppSigningInputViewController
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
			return 2
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
			
			cell.detailTextLabel?.text = "PPQCheck is a way for Apple to check if the app you're opening matches another bundle identifier found on the App Store, the check happens on the first time you open the signed installed application. We have an option for you to avoid this, however you will no longer receive the benefits of notifications and such relating to the default identifier."
			cell.detailTextLabel?.textColor = .label
			cell.textLabel?.numberOfLines = 0
			cell.detailTextLabel?.numberOfLines = 0
//		case 2:
//			cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
//			
//			cell.textLabel?.text = "Information"
//			cell.textLabel?.textColor = .label
//			
//			cell.detailTextLabel?.text = "PPQCheck is a way for Apple to check if the app you're opening matches another bundle identifier found on the App Store, the check happens every time you open the signed installed application. By default we prepended the random string to save you from a headache of getting the Apple ID associated with the certificate locked."
//			cell.detailTextLabel?.textColor = .secondaryLabel
//			cell.textLabel?.numberOfLines = 0
//			cell.detailTextLabel?.numberOfLines = 0
		default: break
		}
		return cell
	}
}
