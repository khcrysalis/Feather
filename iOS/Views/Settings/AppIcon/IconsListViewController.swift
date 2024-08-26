//
//  IconsListViewController.swift
//  feather
//
//  Created by samara on 8/11/24.
//  Copyright (c) 2024 Samara M (khcrysalis)
//

import UIKit

class IconsListViewController: UITableViewController {
		
	public class func altImage(_ name: String) -> UIImage {
		let path = Bundle.main.bundleURL.appendingPathComponent(name + "@2x.png")
		return UIImage(contentsOfFile: path.path) ?? UIImage()
	}
	
	var sections: [String: [AltIcon]] = [
		"Main": [
			AltIcon(displayName: "Feather", author: "Samara", key: nil, image: altImage("AppIcon60x60")),
			AltIcon(displayName: "macOS Feather", author: "Samara", key: "Mac", image: altImage("Mac")),
			AltIcon(displayName: "Evil Feather", author: "Samara", key: "Evil", image: altImage("Evil")),
			AltIcon(displayName: "Classic Feather", author: "Samara", key: "Early", image: altImage("Early"))
		],
		"Wingio": [
			AltIcon(displayName: "Feather", author: "Wingio", key: "Wing", image: altImage("Wing")),
		]
	]
	
	init() { super.init(style: .insetGrouped) }
	required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupViews()
		setupNavigation()
	}
	
	fileprivate func setupViews() {
		self.tableView.delegate = self
		self.tableView.dataSource = self
		self.tableView.rowHeight = 75
	}
	
	fileprivate func setupNavigation() {
		self.title = String.localized("SETTINGS_VIEW_CONTROLLER_CELL_APP_ICON")
		self.navigationItem.largeTitleDisplayMode = .never
	}
	
	private func sectionTitles() -> [String] {
		return Array(sections.keys).sorted()
	}
	
	private func icons(forSection section: Int) -> [AltIcon] {
		let title = sectionTitles()[section]
		return sections[title] ?? []
	}
}

extension IconsListViewController {
	override func numberOfSections(in tableView: UITableView) -> Int { return sectionTitles().count }
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return icons(forSection: section).count }
	override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat { return 40 }
	
	override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let title = sectionTitles()[section]
		let headerView = InsetGroupedSectionHeader(title: title)
		return headerView
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = IconsListTableViewCell()
		let icon = icons(forSection: indexPath.section)[indexPath.row]
		cell.altIcon = icon
		if UIApplication.shared.alternateIconName == icon.key {
			cell.accessoryType = .checkmark
		} else {
			cell.accessoryType = .none
		}
		return cell
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		let icon = icons(forSection: indexPath.section)[indexPath.row]
		
		UIApplication.shared.setAlternateIconName(icon.key) { error in
			Debug.shared.log(message:"\(error?.localizedDescription ?? "Unknown Error")")
		}
		
		self.tableView.reloadRows(at: self.tableView.indexPathsForVisibleRows ?? [IndexPath](), with: .none)
	}
}

struct AltIcon {
	var displayName: String
	var author: String
	var key: String?
	var image: UIImage
}
