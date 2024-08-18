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
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupViews()
		NotificationCenter.default.addObserver(self, selector: #selector(afetch), name: Notification.Name("cfetch"), object: nil)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		setupNavigation()
		fetchSources()
	}
	
	deinit {
		NotificationCenter.default.removeObserver(self, name: Notification.Name("t"), object: nil)
	}
	
	fileprivate func setupViews() {
		self.tableView.dataSource = self
		self.tableView.delegate = self
		self.tableView.tableHeaderView = UIView()
		self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
		self.tableView.register(CertificateViewTableViewCell.self, forCellReuseIdentifier: "CertificateCell")
		self.tableView.register(CertificateViewAddTableViewCell.self, forCellReuseIdentifier: "AddCell")
	}
	
	fileprivate func setupNavigation() {
		self.title = "Certificates"
		self.navigationController?.navigationBar.prefersLargeTitles = false
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
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch section {
		case 0: return 1
		case 1: return certs?.count ?? 0
		default: return 0
		}
	}
	
	override func numberOfSections(in tableView: UITableView) -> Int { return 2 }
	override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat { return 0 }
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if indexPath.section == 0 {
			let cell = tableView.dequeueReusableCell(withIdentifier: "AddCell", for: indexPath) as! CertificateViewAddTableViewCell
			
			cell.configure(with: "Add Certificates", description: "Tap to add a certificate")
			
			cell.selectionStyle = .none
			return cell
		} else {
			let cell = tableView.dequeueReusableCell(withIdentifier: "CertificateCell", for: indexPath) as! CertificateViewTableViewCell
			let certificate = certs![indexPath.row]
			cell.configure(with: certificate, isSelected: Preferences.selectedCert == indexPath.row)
			cell.selectionStyle = .none
			return cell
		}
	}
	
	override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		if indexPath.section == 0 {
			return nil
		}
		
		let source = certs![indexPath.row]
		
		let configuration = UIContextMenuConfiguration(identifier: nil, actionProvider: { _ in
			return UIMenu(title: "", image: nil, identifier: nil, options: [], children: [
				UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive, handler: {_ in
					if Preferences.selectedCert != indexPath.row {
						do {
							CoreDataManager.shared.deleteAllCertificateContent(for: source)
							self.certs?.remove(at: indexPath.row)
							tableView.deleteRows(at: [indexPath], with: .automatic)
						}
					} else {
						DispatchQueue.main.async {
							let alert = UIAlertController(title: "You don't want to do this!", message: "You're trying to delete a selected certificate, try again later when you have another certificate on hand.", preferredStyle: UIAlertController.Style.alert)
							alert.addAction(UIAlertAction(title: "Lame", style: UIAlertAction.Style.default, handler: nil))
							self.present(alert, animated: true, completion: nil)
						}
					}
				})
			])
		})
		return configuration
	}
	
	override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		switch section {
		case 0:
			return "Supported file formats:\n\n- P12 (.p12)\n- Mobile Provision (.mobileprovision)\n\nMake sure your certificates are valid and are able to sideload to your device!"
		default:
			return nil
		}
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if indexPath.section == 0 {
			addCert()
		} else {
			let previousSelectedCert = Preferences.selectedCert
			
			Preferences.selectedCert = indexPath.row
			
			var indexPathsToReload = [indexPath]
			if previousSelectedCert != indexPath.row {
				indexPathsToReload.append(IndexPath(row: previousSelectedCert, section: 1))
			}
			
			tableView.reloadRows(at: indexPathsToReload, with: .fade)
			tableView.deselectRow(at: indexPath, animated: true)
		}
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
