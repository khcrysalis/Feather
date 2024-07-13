//
//  AppsViewController.swift
//  feather
//
//  Created by samara on 5/19/24.
//

import UIKit
import CoreData

class AppsViewController: UITableViewController {
	let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
	
	var downlaodedApps: [DownloadedApps]?
	var signedApps: [SignedApps]?

	public lazy var emptyStackView = EmptyPageStackView()

	lazy var segmentedControl: UISegmentedControl = {
		let sc = RoundedSegmentedControl(items: ["Unsigned", "Signed"])
		sc.selectedSegmentIndex = 0
		return sc
	}()
	
	@objc func segmentChanged(_ sender: UISegmentedControl) {
		self.tableView.reloadSections(IndexSet(integer: 0), with: .fade)
		switch segmentedControl.selectedSegmentIndex {
		case 0:
			showEmptyView(source: self.downlaodedApps ?? [])
		case 1:
			showEmptyView(source: self.signedApps ?? [])
		default:
			break
		}
	}
	
	init() { super.init(style: .plain) }
	required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(false)
		fetchSources()
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupNavigation()
		setupViews()
		fetchSources()
	}
	
	fileprivate func setupViews() {
		self.segmentedControl.translatesAutoresizingMaskIntoConstraints = false
		self.segmentedControl.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
		self.segmentedControl.layer.cornerRadius = 15.0
		self.segmentedControl.layer.borderWidth = 1.0
		self.segmentedControl.layer.masksToBounds = true
		
		self.tableView.backgroundColor = UIColor(named: "Background")
		self.tableView.dataSource = self
		self.tableView.delegate = self
		self.tableView.register(SourceAppTableViewCell.self, forCellReuseIdentifier: "RoundedBackgroundCell")
		self.tableView.tableHeaderView = segmentedControl
		
		NSLayoutConstraint.activate([
			segmentedControl.widthAnchor.constraint(equalTo: tableView.widthAnchor, constant: -29),
			segmentedControl.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
			segmentedControl.topAnchor.constraint(equalTo: tableView.topAnchor),
			segmentedControl.heightAnchor.constraint(equalToConstant: 36)
		])
		
		emptyStackView.title = "No Apps"
		emptyStackView.text = "Add applications by either importing \nthem or using the Sources tab"
		emptyStackView.buttonText = "Adding Apps Guide"
//		emptyStackView.addButtonTarget(self, action: nil)
		emptyStackView.showsButton = true
		emptyStackView.translatesAutoresizingMaskIntoConstraints = false
		emptyStackView.isHidden = true
		view.addSubview(emptyStackView)
		NSLayoutConstraint.activate([
			emptyStackView.centerXAnchor.constraint(equalTo: view.layoutMarginsGuide.centerXAnchor),
			emptyStackView.centerYAnchor.constraint(equalTo: view.layoutMarginsGuide.centerYAnchor),
		])
	}
	
	fileprivate func setupNavigation() {
		self.navigationController?.navigationBar.prefersLargeTitles = true
		
		var leftBarButtonItems: [UIBarButtonItem] = []
		var rightBarButtonItems: [UIBarButtonItem] = []
		
		let configuration = UIMenu(title: "", children: [
			UIAction(title: "Import from Files", handler: { _ in
				//
			}),
			UIAction(title: "Import from URL", handler: { _ in
				//
			})
			
		])
		
		if let addButton = UIBarButtonItem.createBarButtonItem(symbolName: "plus.circle.fill", paletteColors: [Preferences.appTintColor.uiColor, .systemGray5], menu: configuration) {
			rightBarButtonItems.append(addButton)
		}
		
		navigationItem.leftBarButtonItems = leftBarButtonItems
		navigationItem.rightBarButtonItems = rightBarButtonItems
		
	}
}

extension AppsViewController {
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? { return nil }
	override func numberOfSections(in tableView: UITableView) -> Int { return 1 }
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch segmentedControl.selectedSegmentIndex {
		case 0:
			return downlaodedApps?.count ?? 0
		case 1:
			return signedApps?.count ?? 0
		default:
			return 0
		}
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = AppsTableViewCell(style: .subtitle, reuseIdentifier: "RoundedBackgroundCell")
		cell.selectionStyle = .default
		cell.accessoryType = .disclosureIndicator
		
		let source = getApplication(row: indexPath.row)
		let filePath = getApplicationFilePath(with: source!, row: indexPath.row)
		
		
		if let iconURL = source!.value(forKey: "iconURL") as? String {
			let imagePath = filePath.appendingPathComponent(iconURL)
			
			if let image = self.loadImage(from: imagePath) {
				SectionIcons.sectionImage(to: cell, with: image)
			} else {
				SectionIcons.sectionImage(to: cell, with: UIImage(named: "unknown")!)
			}
		} else {
			SectionIcons.sectionImage(to: cell, with: UIImage(named: "unknown")!)
		}
		
		cell.configure(with: source!, filePath: filePath)
		return cell
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let meow = getApplication(row: indexPath.row)
//		var source: NSManagedObject?
//		let filePath = getApplicationFilePath(with: meow!, row: indexPath.row)
//		showAlertWithImageAndBoldText(with: meow!, filePath: filePath)
		print(meow!)
//		switch segmentedControl.selectedSegmentIndex {
//		case 0:
//			source = self.downlaodedApps?[indexPath.row]
//			showAlertWithImageAndBoldText(with: meow!, filePath: filePath)
//		case 1:
//			source = signedApps?[indexPath.row]
//			break
//		default:
//			break
//		}
		
		tableView.deselectRow(at: indexPath, animated: true)
	}
	
	override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		
		let source = getApplication(row: indexPath.row)
		let filePath = getApplicationFilePath(with: source!, row: indexPath.row, getuuidonly: true)
		
		
		let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completionHandler) in
			do {
				try FileManager.default.removeItem(at: filePath)
			} catch {
				print("Error deleting dir: \(error.localizedDescription)")
			}
			
			self.context.delete(source!)
			
			do {
				try self.context.save()
				
				switch self.segmentedControl.selectedSegmentIndex {
				case 0:
					self.downlaodedApps?.remove(at: indexPath.row)
					self.showEmptyView(source: self.downlaodedApps!)
				case 1:
					self.signedApps?.remove(at: indexPath.row)
					self.showEmptyView(source: self.signedApps!)
				default:
					break
				}
				
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
	
	override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		let source = getApplication(row: indexPath.row)
		let filePath = getApplicationFilePath(with: source!, row: indexPath.row)
		
		let configuration = UIContextMenuConfiguration(identifier: nil, actionProvider: { _ in
			return UIMenu(title: "", image: nil, identifier: nil, options: [], children: [
				UIAction(title: "View Details", image: UIImage(systemName: "info.circle"), handler: {_ in
					

//					self.showAlertWithImageAndBoldText(with: source!, filePath: filePath)
					
					let viewController = AppsInformationViewController()
					viewController.source = source
					viewController.filePath = filePath
					let navigationController = UINavigationController(rootViewController: viewController)
					
					if #available(iOS 15.0, *) {
						if let presentationController = navigationController.presentationController as? UISheetPresentationController {
							presentationController.detents = [.medium(), .large()]
						}
					}
					
					self.present(navigationController, animated: true)
					

				}),
				
				UIAction(title: "Open in Files", image: UIImage(systemName: "folder"), handler: {_ in
					
					let path = filePath.deletingLastPathComponent()
					let path2 = path.absoluteString.replacingOccurrences(of: "file://", with: "shareddocuments://")
					
					UIApplication.shared.open(URL(string: path2)!, options: [:]) { success in
						if success {
							print("File opened successfully.")
						} else {
							print("Failed to open file.")
						}
					}
				})
				
			])
		})
		return configuration
	}	
}

extension AppsViewController {
	func fetchSources() {

		do {
			
			switch segmentedControl.selectedSegmentIndex {
			case 0:
				let fetchRequest: NSFetchRequest<DownloadedApps> = DownloadedApps.fetchRequest()
				let sortDescriptor = NSSortDescriptor(key: "dateAdded", ascending: false)
				fetchRequest.sortDescriptors = [sortDescriptor]
				self.downlaodedApps = try context.fetch(fetchRequest)
				showEmptyView(source: self.downlaodedApps ?? [])
			case 1:
				let fetchRequest: NSFetchRequest<SignedApps> = SignedApps.fetchRequest()
				let sortDescriptor = NSSortDescriptor(key: "dateAdded", ascending: false)
				fetchRequest.sortDescriptors = [sortDescriptor]
				self.signedApps = try context.fetch(fetchRequest)
				showEmptyView(source: self.signedApps ?? [])
			default:
				break
			}
						
			DispatchQueue.main.async {
				self.tableView.reloadData()
			}
		} catch {
			print("Error fetching sources: \(error)")
		}
	}
	
	func showEmptyView<T>(source: [T]) {
		DispatchQueue.main.async {
			let isEmpty = source.isEmpty
			self.emptyStackView.isHidden = !isEmpty
			self.tableView.isScrollEnabled = !isEmpty
			self.tableView.refreshControl = isEmpty ? nil : self.refreshControl
		}
	}
}
