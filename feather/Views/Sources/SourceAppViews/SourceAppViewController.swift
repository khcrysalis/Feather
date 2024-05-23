//
//  SourceAppViewController.swift
//  feather
//
//  Created by samara on 5/22/24.
//

import Foundation
import UIKit

class SourceAppViewController: UIViewController {
	
	var tableView: UITableView!
	
	var apps: [StoreApps] = [] {
		didSet {
			
		}
	}
	
	var name: String? {
		didSet {
			self.title = name
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupNavigation()
		setupViews()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(true)
	}
	
	fileprivate func setupViews() {
		self.tableView = UITableView(frame: .zero, style: .plain)
		self.tableView.translatesAutoresizingMaskIntoConstraints = false
		self.tableView.backgroundColor = UIColor(named: "Background")
		self.tableView.dataSource = self
		self.tableView.delegate = self
		self.tableView.register(AppTableViewCell.self, forCellReuseIdentifier: "CustomCell")

		
		self.view.addSubview(tableView)
		self.tableView.constraintCompletely(to: view)
	}
	
	fileprivate func setupNavigation() {
	}
	
}

extension SourceAppViewController: UITableViewDelegate, UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return apps.count }
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = AppTableViewCell(style: .subtitle, reuseIdentifier: "RoundedBackgroundCell")
		let app = apps[indexPath.row]
		cell.configure(with: app)
		SectionIcons.sectionImage(to: cell, with: UIImage(named: "unknown")!)
		return cell
	}
	
	
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
	}
	
}
