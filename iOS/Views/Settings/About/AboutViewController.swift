//
//  AboutViewController.swift
//  feather
//
//  Created by samara on 7/10/24.
//

import UIKit
import MachO

class AboutViewController: UITableViewController {
	let tintColor = Preferences.appTintColor.uiColor
	var tableData =
	[
		["Device Version", "Architecture", "App Version"]
	]
	
	init() { super.init(style: .insetGrouped) }
	required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(false)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupViews()
		setupNavigation()
	}
	
	fileprivate func setupViews() {
		self.tableView.dataSource = self
		self.tableView.delegate = self
	}
	
	fileprivate func setupNavigation() {
		self.title = "About"
	}

}

extension AboutViewController {
	override func numberOfSections(in tableView: UITableView) -> Int { return 1 }
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return tableData[section].count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let reuseIdentifier = "Cell"
		let cell = UITableViewCell(style: .value1, reuseIdentifier: reuseIdentifier)
		cell.accessoryType = .none
		cell.selectionStyle = .none
		
		let cellText = tableData[indexPath.section][indexPath.row]
		cell.textLabel?.text = cellText
		
		switch cellText {
		case "Device Version":
			cell.detailTextLabel?.text = UIDevice.current.systemVersion
		case "Architecture":
			cell.detailTextLabel?.text = String(cString: NXGetLocalArchInfo().pointee.name)
		case "App Version":
			guard let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else {
				break
			}
			cell.detailTextLabel?.text = appVersion
		case "Build":
			break
		default:
			break
		}
		
		return cell
	}
	
}
