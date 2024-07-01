//
//  AppsViewController.swift
//  feather
//
//  Created by samara on 5/19/24.
//

import UIKit

class AppsViewController: UIViewController {
	
	var tableView: UITableView!
	
	var tableData: [[String]] {
		return [
			["test"]
		]
	}
	
	var sectionTitles: [String] {
		return [
			"",
		]
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		setupViews()
    }
	
	fileprivate func setupViews() {
		self.tableView = UITableView(frame: .zero, style: .insetGrouped)
		self.tableView.translatesAutoresizingMaskIntoConstraints = false
		self.tableView.backgroundColor = UIColor(named: "Background")
		self.tableView.separatorStyle = .none
		self.tableView.dataSource = self
		self.tableView.delegate = self
		self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "RoundedBackgroundCell")
		
		self.view.addSubview(tableView)
		self.tableView.constraintCompletely(to: view)
	}

}
extension AppsViewController: UITableViewDelegate, UITableViewDataSource {
	
	func numberOfSections(in tableView: UITableView) -> Int { return sectionTitles.count }
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return tableData[section].count }
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? { return sectionTitles[section] }
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat { return sectionTitles[section].isEmpty ? 5 : 40 }
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
		cell.selectionStyle = .default
		cell.accessoryType = .none
		
		let cellText = tableData[indexPath.section][indexPath.row]
		cell.textLabel?.text = cellText
		
		switch cellText {
		case "test":
			cell.textLabel?.textColor = UIColor.systemBlue
		default:
			break
		}
		
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let cellText = tableData[indexPath.section][indexPath.row]
		switch cellText {
		case "test":
			break
		default:
			break
		}
		
		tableView.deselectRow(at: indexPath, animated: true)
	}

	
	
}
