//
//  SourceAppViewController.swift
//  feather
//
//  Created by samara on 5/22/24.
//

import Foundation
import UIKit
import Nuke
import AlertKit

class SourceAppViewController: UITableViewController {

	let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
	
	var apps: [StoreApps] = []
	var name: String? { didSet { self.title = name } }
		
	init() { super.init(style: .grouped) }
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
		self.tableView.backgroundColor = UIColor(named: "Background")
		self.tableView.dataSource = self
		self.tableView.delegate = self
		self.tableView.register(SourceAppTableViewCell.self, forCellReuseIdentifier: "CustomCell")
		self.tableView.tableHeaderView = UIView()
	}
	
	fileprivate func setupNavigation() {
		self.navigationItem.largeTitleDisplayMode = .never
	}
}

extension SourceAppViewController {
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return apps.count }
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = SourceAppTableViewCell(style: .subtitle, reuseIdentifier: "RoundedBackgroundCell")
		
		let app = apps[indexPath.row]

		cell.configure(with: app)
		cell.selectionStyle = .none
		cell.getButton.tag = indexPath.row
		cell.getButton.addTarget(self, action: #selector(getButtonTapped(_:)), for: .touchUpInside)
		
		let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(getButtonHold(_:)))
		cell.getButton.addGestureRecognizer(longPressGesture)
		cell.getButton.longPressGestureRecognizer = longPressGesture
		
		if let iconURL = app.value(forKey: "iconURL") as? URL  {
			SectionIcons.loadImageFromURL(from: iconURL, for: cell, at: indexPath, in: tableView)
		} else {
			SectionIcons.sectionImage(to: cell, with: UIImage(named: "unknown")!)
		}
		
		return cell
	}
	
	override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		if apps.isEmpty {
			return nil
		} else {
			return "\(apps.count) Apps"
		}
	}
}

