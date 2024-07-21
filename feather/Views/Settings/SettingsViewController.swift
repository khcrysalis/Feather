//
//  SettingsViewController.swift
//  feather
//
//  Created by samara on 7/7/24.
//

import UIKit
import Nuke

class SettingsViewController: UITableViewController {
	let tintColor = Preferences.appTintColor.uiColor
	var tableData =
	[
		["Acknowledgements", "Submit Feedback", "GitHub Repository"],
		["Support via Donations"],
		["About", "Display"],
		["Debug Logs", "Reset"]
	]
	
	var sectionTitles =
	[
		"Support",
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
		setupCreditsSection()
		setupViews()
		setupNavigation()
	}
	
	fileprivate func setupViews() {
		self.tableView.backgroundColor = UIColor(named: "SettingsBackground")
		self.tableView.dataSource = self
		self.tableView.delegate = self
	}
	
	fileprivate func setupNavigation() {
		self.navigationController?.navigationBar.prefersLargeTitles = true
	}
	
	fileprivate func setupCreditsSection() {
		let credits = CreditsData.getCreditsData()
		var creditsSection: [String] = []
		
		for _ in credits {
			creditsSection.append("Credits Person")
		}
		
		tableData.append(creditsSection)
		sectionTitles.append("Credits")
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
		case 0:
			return "If any issues occur within Feather please report it via the GitHub repository. When submitting an issue, be sure to submit any logs."
		case 1:
			return "Support us if you like Feather! Benefits includes beta versions of Feather and more customization options."
		case 3:
			return "Advanced options, really only for us the developers or users looking to debug issues within Feather.\n\nMaybe this will have some of use to you if you ever have issues?"
		default:
			return nil
		}
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let reuseIdentifier = "Cell"
		let cell = UITableViewCell(style: .value1, reuseIdentifier: reuseIdentifier)
		cell.accessoryType = .none
		cell.selectionStyle = .none
		cell.backgroundColor = UIColor(named: "SettingsCell")
		
		let cellText = tableData[indexPath.section][indexPath.row]
		cell.textLabel?.text = cellText
		
		switch cellText {
		case "Acknowledgements", "Debug Logs":
			cell.accessoryType = .disclosureIndicator
			cell.selectionStyle = .default
		case "About":
			cell.setAccessoryIcon(with: "info.circle")
			cell.selectionStyle = .default
		case "Display":
			cell.setAccessoryIcon(with: "paintbrush")
			cell.selectionStyle = .default
		case "Submit Feedback", "GitHub Repository":
			cell.textLabel?.textColor = tintColor
			cell.setAccessoryIcon(with: "safari")
			cell.selectionStyle = .default
		case "Support via Donations", "Reset":
			cell.textLabel?.textColor = tintColor
			cell.accessoryType = .disclosureIndicator
			cell.selectionStyle = .default
		default:
			break
		}
		
		if sectionTitles[indexPath.section] == "Credits" {
			let personCellIdentifier = "PersonCell"
			let personCell = tableView.dequeueReusableCell(withIdentifier: personCellIdentifier) as? PersonCell ?? PersonCell(style: .default, reuseIdentifier: personCellIdentifier)
			
			personCell.backgroundColor = UIColor(named: "SettingsCell")
			
			let developers = CreditsData.getCreditsData()
			let developer = developers[indexPath.row]
			
			personCell.configure(with: developer)
			if let arrowImage = UIImage(systemName: "arrow.up.forward")?.withTintColor(UIColor.tertiaryLabel, renderingMode: .alwaysOriginal) {
				personCell.accessoryView = UIImageView(image: arrowImage)
			}
			return personCell
		}
		
		return cell
	}


	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let itemTapped = tableData[indexPath.section][indexPath.row]
		switch itemTapped {
		case "About":
			let l = AboutViewController()
			navigationController?.pushViewController(l, animated: true)
		case "Display":
			let l = DisplayViewController()
			navigationController?.pushViewController(l, animated: true)
		case "Acknowledgements":
			let l = LicensesViewController()
			navigationController?.pushViewController(l, animated: true)
		case "Reset":
			let l = ResetViewController()
			navigationController?.pushViewController(l, animated: true)
		default:
			break
		}
		if sectionTitles[indexPath.section] == "Credits" {
			let developers = CreditsData.getCreditsData()
			let developer = developers[indexPath.row]
			if let socialLink = developer.socialLink {
				UIApplication.shared.open(socialLink, options: [:], completionHandler: nil)
			}
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
