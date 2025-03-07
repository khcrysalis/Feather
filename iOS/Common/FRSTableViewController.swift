//
//  FRSTableViewController.swift
//  feather
//
//  Created by samara on 6.03.2025.
//

// Feather Settings TableView Controller

class FRSTableViewController: UITableViewController {
	var tableData: [[String]] = [[]]
	var sectionTitles: [String] = []
	
	init() {
		super.init(style: .insetGrouped)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Navigation
		configureTitleDisplayMode()
		
		// Delegates
		self.tableView.dataSource = self
		self.tableView.delegate = self
	}
	
	private func configureTitleDisplayMode() {
		if isRootViewController() {
			navigationItem.largeTitleDisplayMode = .always
			navigationController?.navigationBar.prefersLargeTitles = true
		} else {
			navigationItem.largeTitleDisplayMode = .never
		}
	}
	
	private func isRootViewController() -> Bool {
		return navigationController?.viewControllers.first === self
	}
	
	func ensureTableDataHasSections() {
		while tableData.count < sectionTitles.count {
			tableData.append([])
		}
	}
}

// MARK: - Tableview overrides

extension FRSTableViewController {
	override func numberOfSections(in tableView: UITableView) -> Int {
		return sectionTitles.count
	}
	
	override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return sectionTitles[section].isEmpty ? 0 : 40
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return tableData[section].count
	}
	
	override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let title = sectionTitles[section]
		let headerView = InsetGroupedSectionHeader(title: title)
		return headerView
	}
}
