//
//  IdentifiersViewController.swift
//  feather
//
//  Created by samara on 26.10.2024.
//

import UIKit

enum IdentifierMode {
	case bundleId
	case displayName
}

class IdentifiersViewController: UITableViewController {
	var signingDataWrapper: SigningDataWrapper
	private var mode: IdentifierMode
	
	init(signingDataWrapper: SigningDataWrapper, mode: IdentifierMode) {
		self.signingDataWrapper = signingDataWrapper
		self.mode = mode
		super.init(style: .insetGrouped)
		title = mode == .bundleId ? 
			String.localized("APP_SIGNING_VIEW_CONTROLLER_CELL_SIGNING_OPTIONS_IDENTIFIERS") :
			String.localized("APP_SIGNING_VIEW_CONTROLLER_CELL_SIGNING_OPTIONS_DISPLAYNAMES")
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
		switch mode {
		case .bundleId:
			return signingDataWrapper.signingOptions.bundleIdConfig.keys.count
		case .displayName:
			return signingDataWrapper.signingOptions.displayNameConfig.keys.count
		}
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 1
	}
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		switch mode {
		case .bundleId:
			let sortedKeys = signingDataWrapper.signingOptions.bundleIdConfig.keys.sorted()
			return sortedKeys[section]
		case .displayName:
			let sortedKeys = signingDataWrapper.signingOptions.displayNameConfig.keys.sorted()
			return sortedKeys[section]
		}
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "IdentifierCell", for: indexPath)
		
		switch mode {
		case .bundleId:
			let key = signingDataWrapper.signingOptions.bundleIdConfig.keys.sorted()[indexPath.section]
			cell.textLabel?.text = signingDataWrapper.signingOptions.bundleIdConfig[key]
		case .displayName:
			let key = signingDataWrapper.signingOptions.displayNameConfig.keys.sorted()[indexPath.section]
			cell.textLabel?.text = signingDataWrapper.signingOptions.displayNameConfig[key]
		}
		
		cell.textLabel?.textColor = .secondaryLabel
		cell.selectionStyle = .none
		return cell
	}
	
	override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		let deleteAction = UIContextualAction(style: .destructive, title: String.localized("DELETE")) { [weak self] _, _, completionHandler in
			self?.deleteIdentifier(at: indexPath.section)
			completionHandler(true)
		}
		return UISwipeActionsConfiguration(actions: [deleteAction])
	}
	
	private func deleteIdentifier(at index: Int) {
		switch mode {
		case .bundleId:
			let key = signingDataWrapper.signingOptions.bundleIdConfig.keys.sorted()[index]
			signingDataWrapper.signingOptions.bundleIdConfig.removeValue(forKey: key)
		case .displayName:
			let key = signingDataWrapper.signingOptions.displayNameConfig.keys.sorted()[index]
			signingDataWrapper.signingOptions.displayNameConfig.removeValue(forKey: key)
		}
		NotificationCenter.default.post(name: Notification.Name("saveOptions"), object: nil)
		tableView.reloadData()
	}
	
	@objc private func addIdentifierTapped() {
		let addVC = AddIdentifierViewController(mode: mode)
		addVC.onAdd = { [weak self] identifier, replacement in
			switch self?.mode {
			case .bundleId:
				self?.signingDataWrapper.signingOptions.bundleIdConfig[identifier] = replacement
			case .displayName:
				self?.signingDataWrapper.signingOptions.displayNameConfig[identifier] = replacement
			case .none:
				break
			}
			NotificationCenter.default.post(name: Notification.Name("saveOptions"), object: nil)
			self?.tableView.reloadData()
		}
		navigationController?.pushViewController(addVC, animated: true)
	}
}
