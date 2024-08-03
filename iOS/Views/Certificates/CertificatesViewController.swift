//
//  CertificatesViewController.swift
//  feather
//
//  Created by samara on 7/7/24.
//

import UIKit
import CoreData

class CertificatesViewController: UITableViewController {
	var certs: [Certificate]?
		
	init() { super.init(style: .insetGrouped) }
	required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(false)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupViews()
		setupNavigation()
		fetchSources()
		NotificationCenter.default.addObserver(self, selector: #selector(afetch), name: Notification.Name("cfetch"), object: nil)
	}
	
	deinit {
		NotificationCenter.default.removeObserver(self, name: Notification.Name("t"), object: nil)
	}
	
	fileprivate func setupViews() {
		self.tableView.dataSource = self
		self.tableView.delegate = self
		self.tableView.tableHeaderView = UIView()
		self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
	}
	
	fileprivate func setupNavigation() {
		self.navigationController?.navigationBar.prefersLargeTitles = true
		
		var leftBarButtonItems: [UIBarButtonItem] = []
		var rightBarButtonItems: [UIBarButtonItem] = []
		
		let addButton = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain,target: self,action: #selector(addCert))
		rightBarButtonItems.append(addButton)
		
		navigationItem.leftBarButtonItems = leftBarButtonItems
		navigationItem.rightBarButtonItems = rightBarButtonItems
		
	}
	
	@objc func addCert() {
		let viewController = CertImportingVC()
		let navigationController = UINavigationController(rootViewController: viewController)
		
		if #available(iOS 15.0, *) {
			if let presentationController = navigationController.presentationController as? UISheetPresentationController {
				presentationController.detents = [.medium(), .large()]
			}
		}
		
		self.present(navigationController, animated: true)
	}
}
extension CertificatesViewController {
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return certs?.count ?? 0 }
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
		
		let source = certs![indexPath.row]
		cell.textLabel?.text = source.certData?.teamName
		cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 17)
		cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 13)
		cell.selectionStyle = .none
		
		if let expirationDate = source.certData?.expirationDate {
			let currentDate = Date()
			
			if expirationDate < currentDate {
				cell.detailTextLabel?.text = "Expiration: \(expirationDate.description) (Expired)"
				cell.detailTextLabel?.textColor = .red
			} else {
				cell.detailTextLabel?.text = "Expiration: \(expirationDate.description)"
				cell.detailTextLabel?.textColor = .secondaryLabel
			}
		} else {
			cell.detailTextLabel?.text = "Expiration: Unknown"
			cell.detailTextLabel?.textColor = .secondaryLabel
		}
		
		if Preferences.selectedCert == indexPath.row {
			cell.accessoryType = .checkmark
		}
		
		return cell
	}
	override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		
		let source = certs![indexPath.row]
		
		let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completionHandler) in
			CoreDataManager.shared.deleteAllCertificateContent(for: source)
			
			do {
				self.certs?.remove(at: indexPath.row)
				tableView.deleteRows(at: [indexPath], with: .automatic)
			}
			
			completionHandler(true)
		}
		
		deleteAction.backgroundColor = UIColor.red
		let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
		configuration.performsFirstActionWithFullSwipe = true

		return configuration
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let previousSelectedCert = Preferences.selectedCert
		
		Preferences.selectedCert = indexPath.row
		
		var indexPathsToReload = [indexPath]
		if previousSelectedCert != indexPath.row {
			indexPathsToReload.append(IndexPath(row: previousSelectedCert, section: 0))
		}
		
		tableView.reloadRows(at: indexPathsToReload, with: .fade)
		tableView.deselectRow(at: indexPath, animated: true)
	}


	
}

extension CertificatesViewController {
	@objc func afetch() { self.fetchSources() }
	func fetchSources() {
		do {
			self.certs = CoreDataManager.shared.getDatedCertificate()
			DispatchQueue.main.async { self.tableView.reloadData() }
		}
	}
}
