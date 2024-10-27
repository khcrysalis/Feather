//
//  IdentifiersViewController.swift
//  feather
//
//  Created by samara on 26.10.2024.
//

import UIKit

class IdentifiersViewController: UITableViewController {
	var signingDataWrapper: SigningDataWrapper
	private var newIdentifier: String = ""
	private var newReplacement: String = ""
	
	init(signingDataWrapper: SigningDataWrapper) {
		self.signingDataWrapper = signingDataWrapper
		super.init(style: .insetGrouped)
		title = "Identifiers"
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		navigationItem.rightBarButtonItem = UIBarButtonItem(
			barButtonSystemItem: .add,
			target: self,
			action: #selector(addIdentifierTapped)
		)
		
		tableView.register(UITableViewCell.self, forCellReuseIdentifier: "IdentifierCell")
	}
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return signingDataWrapper.signingOptions.bundleIdConfig.keys.count
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 1
	}
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		let sortedKeys = signingDataWrapper.signingOptions.bundleIdConfig.keys.sorted()
		return sortedKeys[section]
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "IdentifierCell", for: indexPath)
		
		let key = signingDataWrapper.signingOptions.bundleIdConfig.keys.sorted()[indexPath.section]
		cell.textLabel?.text = signingDataWrapper.signingOptions.bundleIdConfig[key]
		cell.textLabel?.textColor = .secondaryLabel
		cell.selectionStyle = .none
		return cell
	}
	
	override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completionHandler in
			self?.deleteIdentifier(at: indexPath.section)
			completionHandler(true)
		}
		return UISwipeActionsConfiguration(actions: [deleteAction])
	}
	
	private func deleteIdentifier(at index: Int) {
		let key = signingDataWrapper.signingOptions.bundleIdConfig.keys.sorted()[index]
		signingDataWrapper.signingOptions.bundleIdConfig.removeValue(forKey: key)
		tableView.reloadData()
	}
	
	@objc private func addIdentifierTapped() {
		let addVC = AddIdentifierViewController()
		addVC.onAdd = { [weak self] identifier, replacement in
			self?.signingDataWrapper.signingOptions.bundleIdConfig[identifier] = replacement
			self?.tableView.reloadData()
		}
		navigationController?.pushViewController(addVC, animated: true)
	}
}
