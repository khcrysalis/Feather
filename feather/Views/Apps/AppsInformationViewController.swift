//
//  AppsInformationViewController.swift
//  feather
//
//  Created by samara on 7/2/24.
//

import Foundation
import UIKit
import CoreData

class AppsInformationViewController: UIViewController {
	var tableView: UITableView!

	var tableData = 
	[
		[
			"Name",
			"Version",
			"Identifier",
			"Size"
		],
		[
			"Date Added"
		],
		[
			"Bundle Name",
			"Bundle Path",
			"Icon File",
			"UUID"
		],
		[
			"Open in Files"
		]
	]
	
	var sectionTitles = 
	[
		"Application",
		"",
		"Bundle",
		""
	]
	
	var source: NSManagedObject! {didSet {}}
	var filePath: URL! {didSet {}}
	var headerImage: UIImage!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.setupViews()
		self.setupNavigation()
	}
	
	fileprivate func setupViews() {
		self.tableView = UITableView(frame: .zero, style: .insetGrouped)
		self.tableView.translatesAutoresizingMaskIntoConstraints = false
		self.tableView.dataSource = self
		self.tableView.backgroundColor = UIColor(named: "Background")
		self.tableView.delegate = self
		self.tableView.tableHeaderView = configureHeaderView()
		
		if !FileManager.default.fileExists(atPath: filePath.path) {
			tableData.insert(["Deleted File"], at: 0)
			sectionTitles.insert("", at: 0)
		}
		
		self.view.addSubview(tableView)
		self.tableView.constraintCompletely(to: view)
	}
	
	private func configureHeaderView() -> UIView {
		let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 100))
		headerView.backgroundColor = .clear
		
		if let iconURL = source.value(forKey: "iconURL") as? String {
			let imagePath = filePath.appendingPathComponent(iconURL)
			if let image = AppsViewController().loadImage(from: imagePath) {
				headerImage = image
			} else {
				headerImage = UIImage(named: "unknown")!
			}
		} else {
			headerImage = UIImage(named: "unknown")!
		}

		let imageView = UIImageView(image: headerImage)
		imageView.contentMode = .scaleAspectFit
		imageView.frame = CGRect(x: (view.frame.width - 80) / 2, y: 0, width: 80, height: 80)
		imageView.layer.cornerRadius = 18
		imageView.layer.borderWidth = 1
		imageView.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.3).cgColor
		imageView.layer.cornerCurve = .continuous
		imageView.layer.masksToBounds = true
		headerView.addSubview(imageView)

		return headerView
	}
	
	fileprivate func setupNavigation() {
		self.title = nil
		self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .close, target: self, action: #selector(closeSheet))
	}
	
	@objc func closeSheet() {
		dismiss(animated: true, completion: nil)
	}
	
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		let threshold: CGFloat = 40
		
		if scrollView.contentOffset.y > threshold {
			if let aa = source.value(forKey: "name") as? String {
				self.title = aa
			}
		} else {
			self.title = nil
		}
	}
}

extension AppsInformationViewController: UITableViewDelegate, UITableViewDataSource {
	func numberOfSections(in tableView: UITableView) -> Int { return sectionTitles.count }
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return tableData[section].count }
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? { return sectionTitles[section] }
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat { return sectionTitles[section].isEmpty ? 5 : 40 }
	
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let title = sectionTitles[section]
		let headerView = CustomSectionHeader(title: title)
		return headerView
	}
	
	func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		switch section {
		default:
			return nil
		}
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let reuseIdentifier = "Cell"
		var cell = UITableViewCell(style: .value1, reuseIdentifier: reuseIdentifier)
		cell.accessoryType = .none
		cell.selectionStyle = .none
		cell.backgroundColor = UIColor(named: "Cells")
		
		let cellText = tableData[indexPath.section][indexPath.row]
		cell.textLabel?.text = cellText
		
		switch cellText {
		case "Deleted File":
			cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
			cell.backgroundColor = UIColor(named: "Cells")
			
			cell.textLabel?.text = "File has been deleted."
			cell.textLabel?.textColor = .systemRed
			
			cell.detailTextLabel?.text = "This is a useless entry, it does not have a file and Feather will not allow you to install it. It's recommended you delete by swiping on the cell in the Apps tab."
			cell.detailTextLabel?.textColor = .systemYellow
			
			
			
//			cell.textLabel?.textAlignment = .center
//			cell.detailTextLabel?.textAlignment = .center
			cell.textLabel?.numberOfLines = 0
			cell.detailTextLabel?.numberOfLines = 0
			
		case "Name":
			if let aa = source.value(forKey: "name") as? String {
				cell.detailTextLabel?.text = aa
			}
		case "Version":
			if let aa = source.value(forKey: "version") as? String {
				cell.detailTextLabel?.text = aa
			}
		case "Size":
			cell.detailTextLabel?.text = "test"
		case "Date Added":
			if let aa = source.value(forKey: "dateAdded") as? Date {
				let dateFormatter = DateFormatter()
				dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
				let dateString = dateFormatter.string(from: aa)
				cell.detailTextLabel?.text = dateString
			}
		case "Bundle Name":
			if let aa = source.value(forKey: "appPath") as? String {
				cell.detailTextLabel?.text = aa
			}
		case "Identifier":
			if let aa = source.value(forKey: "bundleidentifier") as? String {
				cell.detailTextLabel?.text = aa
			}
		case "Icon File":
			if let aa = source.value(forKey: "iconURL") as? String {
				cell.detailTextLabel?.text = aa
			}
		case "UUID":
			if let aa = source.value(forKey: "uuid") as? String {
				cell.detailTextLabel?.text = aa
			}
			
		case "Bundle Path":
			cell.detailTextLabel?.text = self.filePath.path
		case "Open in Files":
			cell.textLabel?.textColor = Preferences.appTintColor.uiColor
			cell.textLabel?.textAlignment = .center
			cell.selectionStyle = .default
		default:
			break
		}
		return cell
	}


	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let itemTapped = tableData[indexPath.section][indexPath.row]
		switch itemTapped {
		case "Open in Files":
			guard let fileURL = self.filePath else {
				print("File path is nil or invalid.")
				return
			}
			
			let path = fileURL.deletingLastPathComponent()
			let path2 = path.absoluteString.replacingOccurrences(of: "file://", with: "shareddocuments://")
			
			UIApplication.shared.open(URL(string: path2)!, options: [:]) { success in
				if success {
					print("File opened successfully.")
				} else {
					print("Failed to open file.")
				}
			}
		default:
			break
		}
		
		tableView.deselectRow(at: indexPath, animated: true)
	}


}

