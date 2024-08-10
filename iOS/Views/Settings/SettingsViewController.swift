//
//  SettingsViewController.swift
//  feather
//
//  Created by samara on 7/7/24.
//

import UIKit
import Nuke

class SettingsViewController: UITableViewController {
	var tableData =
	[
		["Donate"],
		["About Feather", "Submit Feedback", "GitHub Repository"],
		["Current Certificate", "Add Certificate"],
		["Signing Configuration"],
		["Display", "App Icon"],
		["Debug Logs", "Reset"]
	]
	
	var sectionTitles =
	[
		"",
		"",
		"Signing",
		"",
		"General",
		"Advanced"
	]
	
	init() { super.init(style: .insetGrouped) }
	required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(false)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupViews()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		setupNavigation()
	}
	
	fileprivate func setupViews() {
		self.tableView.dataSource = self
		self.tableView.delegate = self
	}
	
	fileprivate func setupNavigation() {
		self.navigationController?.navigationBar.prefersLargeTitles = true
	}
}

extension SettingsViewController {
	override func numberOfSections(in tableView: UITableView) -> Int { return sectionTitles.count }
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return tableData[section].count
	}
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? { return sectionTitles[section] }
	override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat { return sectionTitles[section].isEmpty ? 0 : 40 }
	
	override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let title = sectionTitles[section]
		let headerView = InsetGroupedSectionHeader(title: title)
		return headerView
	}
	
	override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		switch section {
		case 1:
			return "If any issues occur within Feather please report it via the GitHub repository. When submitting an issue, be sure to submit any logs."
		default:
			return nil
		}
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let reuseIdentifier = "Cell"
		var cell = UITableViewCell(style: .value1, reuseIdentifier: reuseIdentifier)
		cell.accessoryType = .none
		cell.selectionStyle = .none
		
		let cellText = tableData[indexPath.section][indexPath.row]
		cell.textLabel?.text = cellText
		
		switch cellText {
		case "Donate":
			cell = DonationTableViewCell(style: .default, reuseIdentifier: "D")
			cell.selectionStyle = .none
		case "Debug Logs", "Signing Configuration":
			cell.accessoryType = .disclosureIndicator
			cell.selectionStyle = .default
		case "About Feather":
			cell.setAccessoryIcon(with: "info.circle")
			cell.selectionStyle = .default
		case "Display":
			cell.setAccessoryIcon(with: "paintbrush")
			cell.selectionStyle = .default
		case "Submit Feedback", "GitHub Repository":
			cell.textLabel?.textColor = .tintColor
			cell.setAccessoryIcon(with: "safari")
			cell.selectionStyle = .default
		case "Reset":
			cell.textLabel?.textColor = .tintColor
			cell.accessoryType = .disclosureIndicator
			cell.selectionStyle = .default
		case "Add Certificate":
			cell.setAccessoryIcon(with: "plus")
			cell.selectionStyle = .default
		case "Current Certificate":
			if let hasGotCert = CoreDataManager.shared.getCurrentCertificate() {
				let cell = CertificateViewTableViewCell()
				cell.configure(with: hasGotCert, isSelected: false)
				cell.selectionStyle = .none
				return cell
			} else {
				cell.textLabel?.text = "No certificates selected"
				cell.textLabel?.textColor = .secondaryLabel
				cell.selectionStyle = .none
			}
		default:
			break
		}
		
		return cell
	}


	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let itemTapped = tableData[indexPath.section][indexPath.row]
		switch itemTapped {
		case "Display":
			let l = DisplayViewController()
			navigationController?.pushViewController(l, animated: true)
		case "About Feather":
			let l = AboutViewController()
			navigationController?.pushViewController(l, animated: true)
		case "Reset":
			let l = ResetViewController()
			navigationController?.pushViewController(l, animated: true)
		case "Add Certificate":
			let l = CertificatesViewController()
			navigationController?.pushViewController(l, animated: true)
		default:
			break
		}
		
		tableView.deselectRow(at: indexPath, animated: true)
	}
	
}

extension UITableViewCell {
	func setAccessoryIcon(with symbolName: String, tintColor: UIColor = .tertiaryLabel, renderingMode: UIImage.RenderingMode = .alwaysOriginal) {
		if let image = UIImage(systemName: symbolName)?.withTintColor(tintColor, renderingMode: renderingMode) {
			let imageView = UIImageView(image: image)
			self.accessoryView = imageView
		} else {
			self.accessoryView = nil
		}
	}
}
