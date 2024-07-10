//
//  DisplayViewController.swift
//  nekofiles
//
//  Created by samara on 2/24/24.
//

import UIKit

class DisplayViewController: UIViewController {
	var tableView: UITableView!

	let tableData = [
		["Appearence"],
		["Collection View"]
	]
	
	var sectionTitles = [
		"",
		"Tint Color"
	]
	
	let collectionData = ["Default", "Berry", "Sky", "Orange", "Peach", "Dragon", "Cactus"]
	let collectionDataColors = ["8c96ff", "ff7a83", "6acef6", "ffbd7a", "ebcb8d", "eb8db4", "75d651"]
	
	override func viewDidLoad() {
		super.viewDidLoad()
		title = "Display"

		self.tableView = UITableView(frame: .zero, style: .insetGrouped)
		self.tableView.backgroundColor = UIColor(named: "SettingsBackground")
		self.tableView.delegate = self
		self.tableView.dataSource = self
		self.tableView.register(CollectionTableViewCell.self, forCellReuseIdentifier: "CollectionCell")
		self.tableView.translatesAutoresizingMaskIntoConstraints = false
		
		self.view.addSubview(tableView)
		self.tableView.constraintCompletely(to: view)
	}
	
	func updateAppearance(with style: UIUserInterfaceStyle) {
		view.window?.overrideUserInterfaceStyle = style
		Preferences.preferredInterfaceStyle = style.rawValue
	}
}

extension DisplayViewController: UITableViewDelegate, UITableViewDataSource {
	func numberOfSections(in tableView: UITableView) -> Int { return sectionTitles.count }
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return tableData[section].count }
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? { return sectionTitles[section] }
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat { return sectionTitles[section].isEmpty ? 5 : 40 }
	
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let title = sectionTitles[section]
		let headerView = CustomSectionHeader(title: title)
		return headerView
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let reuseIdentifier = "Cell"
		let cell = UITableViewCell(style: .default, reuseIdentifier: reuseIdentifier)
		cell.selectionStyle = .none
		let cellText = tableData[indexPath.section][indexPath.row]
		cell.backgroundColor = UIColor(named: "SettingsCell")
		switch cellText {
		case "Appearence":
			cell.textLabel?.text = "Appearance"
			let segmentedControl = UISegmentedControl(items: UIUserInterfaceStyle.allCases.map { $0.description })
			segmentedControl.selectedSegmentIndex = UIUserInterfaceStyle.allCases.firstIndex { $0.rawValue == Preferences.preferredInterfaceStyle } ?? 0
			segmentedControl.addTarget(self, action: #selector(appearanceSegmentedControlChanged(_:)), for: .valueChanged)
			cell.accessoryView = segmentedControl

		case "Collection View":
			let cell = tableView.dequeueReusableCell(withIdentifier: "CollectionCell", for: indexPath) as! CollectionTableViewCell
			cell.setData(collectionData: collectionData, colors: collectionDataColors)
			cell.backgroundColor = .clear
			return cell
		default:
			break
		}
		return cell
	}
	
	@objc private func appearanceSegmentedControlChanged(_ sender: UISegmentedControl) {
		let selectedStyle = UIUserInterfaceStyle.allCases[sender.selectedSegmentIndex]
		updateAppearance(with: selectedStyle)
	}
}

extension UIUserInterfaceStyle: CaseIterable {
	public static var allCases: [UIUserInterfaceStyle] = [.unspecified, .dark, .light]
	var description: String {
		switch self {
		case .unspecified:
			return "System"
		case .light:
			return "Light"
		case .dark:
			return "Dark"
		@unknown default:
			return "Unknown Mode"
		}
	}
}
