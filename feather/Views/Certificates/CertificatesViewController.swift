//
//  CertificatesViewController.swift
//  feather
//
//  Created by samara on 7/7/24.
//

import UIKit
import CoreData

class CertificatesViewController: UITableViewController {
	let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

	var certs: [Certificate]?
	
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
		fetchSources()
		NotificationCenter.default.addObserver(self, selector: #selector(afetch), name: Notification.Name("t"), object: nil)
	}
	
	deinit {
		NotificationCenter.default.removeObserver(self, name: Notification.Name("t"), object: nil)
	}
	
	fileprivate func setupViews() {
		self.tableView.backgroundColor = UIColor(named: "Background")
		self.tableView.dataSource = self
		self.tableView.delegate = self
		self.tableView.tableHeaderView = UIView()
		self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
	}
	
	fileprivate func setupNavigation() {
		self.navigationController?.navigationBar.prefersLargeTitles = true
		
		var leftBarButtonItems: [UIBarButtonItem] = []
		var rightBarButtonItems: [UIBarButtonItem] = []
		
		if !isSelectMode {

			if let addButton = UIBarButtonItem.createBarButtonItem(symbolName: "plus.circle.fill", paletteColors: [Preferences.appTintColor.uiColor, .systemGray5], target: self,action: #selector(addCert)) {
				rightBarButtonItems.append(addButton)
			}
		} else {
			let d = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneEditingButton))
			leftBarButtonItems.append(d)
		}
		
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
		cell.backgroundColor = UIColor(named: "Background")
		
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
		
		return cell
	}
	override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		
		let source = certs![indexPath.row]
		let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
		var p = documentsDirectory
			.appendingPathComponent("Certificates")
			.appendingPathComponent((source.uuid)!)
		
		let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completionHandler) in
			do {
				try FileManager.default.removeItem(at: p)
			} catch {
				print("Error deleting dir: \(error.localizedDescription)")
			}
			
			self.context.delete(source)
			
			do {
				try self.context.save()
				
				self.certs?.remove(at: indexPath.row)
				
				tableView.deleteRows(at: [indexPath], with: .automatic)
			} catch {
				print("Error deleting data: \(error.localizedDescription)")
			}
			
			completionHandler(true)
		}
		
		deleteAction.backgroundColor = UIColor.red
		let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
		configuration.performsFirstActionWithFullSwipe = true

		return configuration
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
extension CertificatesViewController {
	@objc func afetch() {
		self.fetchSources()
	}
	func fetchSources() {
		let fetchRequest: NSFetchRequest<Certificate> = Certificate.fetchRequest()
		let sortDescriptor = NSSortDescriptor(key: "dateAdded", ascending: false)
		fetchRequest.sortDescriptors = [sortDescriptor]
		
		do {
			self.certs = try context.fetch(fetchRequest)
			
			DispatchQueue.main.async {
				self.tableView.reloadData()
			}
		} catch {
			print("Error fetching sources: \(error)")
		}
	}
}
