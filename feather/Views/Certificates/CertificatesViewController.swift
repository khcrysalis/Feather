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
	}
}
