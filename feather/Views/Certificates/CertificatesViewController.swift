//
//  CertificatesViewController.swift
//  feather
//
//  Created by samara on 7/7/24.
//

import UIKit

class CertificatesViewController: UITableViewController {
	let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

	public lazy var emptyStackView = EmptyPageStackView()
	
	init() { super.init(style: .plain) }
	required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
	
	var isSelectMode: Bool = false {
		didSet {
			tableView.allowsMultipleSelection = isSelectMode
			setupNavigation()
		}
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(false)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupViews()
		setupNavigation()
	}
	
	fileprivate func setupViews() {
		self.tableView.backgroundColor = UIColor(named: "Background")
		self.tableView.dataSource = self
		self.tableView.delegate = self
		self.tableView.tableHeaderView = UIView()
	}
	
	fileprivate func setupNavigation() {
		self.navigationController?.navigationBar.prefersLargeTitles = true
		
		var leftBarButtonItems: [UIBarButtonItem] = []
		var rightBarButtonItems: [UIBarButtonItem] = []
		
		if !isSelectMode {

			let configuration = UIMenu(title: "", children: [
				UIAction(title: "Add Batch Certificates", handler: { _ in
					//
				}),
				UIAction(title: "Add Certificate", handler: { _ in
					//
				})
				
			])

			if let addButton = UIBarButtonItem.createBarButtonItem(symbolName: "plus.circle.fill", paletteColors: [Preferences.appTintColor.uiColor, .systemGray5], menu: configuration) {
				rightBarButtonItems.append(addButton)
			}
		} else {
			let d = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneEditingButton))
			leftBarButtonItems.append(d)
		}
		
		navigationItem.leftBarButtonItems = leftBarButtonItems
		navigationItem.rightBarButtonItems = rightBarButtonItems
		
	}
}
extension CertificatesViewController {
	@objc func doneEditingButton() { setEditing(false, animated: true) }
	@objc func setEditingButton() { setEditing(true, animated: true) }
	override func setEditing(_ editing: Bool, animated: Bool) {
		super.setEditing(editing, animated: animated)
		isSelectMode = editing
		tableView.setEditing(editing, animated: true)
		tableView.allowsMultipleSelection = false
	}
}
