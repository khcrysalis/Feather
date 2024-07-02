//
//  AppsViewController.swift
//  feather
//
//  Created by samara on 5/19/24.
//

import UIKit
import CoreData

class AppsViewController: UIViewController {
	let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
	var tableView: UITableView!
	
	var downlaodedApps: [DownloadedApps]?
	var signedApps: [SignedApps]?

	let segmentedControl: UISegmentedControl = {
		let sc = UISegmentedControl(items: ["Unsigned", "Signed"])
		sc.selectedSegmentIndex = 0
		return sc
	}()


	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(false)
		fetchSources()
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupViews()
		setupNavigation()
		fetchSources()
	}
	
	fileprivate func setupViews() {
		self.segmentedControl.translatesAutoresizingMaskIntoConstraints = false
		self.segmentedControl.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
		
		self.tableView = UITableView(frame: .zero, style: .plain)
		self.tableView.translatesAutoresizingMaskIntoConstraints = false
		self.view.backgroundColor = UIColor(named: "Background")
		self.tableView.backgroundColor = UIColor(named: "Background")
		self.tableView.dataSource = self
		self.tableView.delegate = self
		self.tableView.register(SourceAppTableViewCell.self, forCellReuseIdentifier: "RoundedBackgroundCell")
		
		let containerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 34))
		containerView.addSubview(segmentedControl)
		
		NSLayoutConstraint.activate([
			segmentedControl.topAnchor.constraint(equalTo: containerView.topAnchor),
			segmentedControl.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 15),
			segmentedControl.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -15),
			segmentedControl.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
		])
		
		self.tableView.tableHeaderView = containerView
		
		self.view.addSubview(tableView)

		NSLayoutConstraint.activate([
			tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
			tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
		])
	}

	
	fileprivate func setupNavigation() {
//		self.navigationController?.navigationBar.prefersLargeTitles = true
//		self.navigationItem.largeTitleDisplayMode = .always
		
//		var leftBarButtonItems: [UIBarButtonItem] = []
//		var rightBarButtonItems: [UIBarButtonItem] = []
//		
//		navigationItem.leftBarButtonItems = leftBarButtonItems
//		navigationItem.rightBarButtonItems = rightBarButtonItems
	}
	
	@objc func segmentChanged(_ sender: UISegmentedControl) {
		tableView.reloadData()
	}
}

extension AppsViewController: UITableViewDelegate, UITableViewDataSource {
	
	func numberOfSections(in tableView: UITableView) -> Int { return 1 }
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		switch segmentedControl.selectedSegmentIndex {
		case 0:
			return downlaodedApps?.count ?? 0
		case 1:
			return signedApps?.count ?? 0
		default:
			return 0
		}
		
	}
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? { return nil }
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = AppsTableViewCell(style: .subtitle, reuseIdentifier: "RoundedBackgroundCell")
		cell.selectionStyle = .default
		cell.accessoryType = .none
		cell.backgroundColor = UIColor(named: "Background")
		
		var source: NSManagedObject?
		var path = ""
		let size = CGSize(width: 52, height: 52)
		let radius = 12
		var filePath = URL(string: "")
		switch segmentedControl.selectedSegmentIndex {
		case 0:
			source = downlaodedApps?[indexPath.row]
			path = "Unsigned"
		case 1:
			source = signedApps?[indexPath.row]
			path = "Signed"
		default:
			break
		}
					
		if let uuid = source!.value(forKey: "uuid") as? String,
		   let appPath = source!.value(forKey: "appPath") as? String {
			
			let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
			var imagePath = documentsDirectory
				.appendingPathComponent("Apps")
				.appendingPathComponent(path)
				.appendingPathComponent(uuid)
				.appendingPathComponent(appPath)
				
			filePath = imagePath
			
			if let iconURL = source!.value(forKey: "iconURL") as? String {
				imagePath = imagePath.appendingPathComponent(iconURL)
				
				if let image = self.loadImage(from: imagePath) {
					SectionIcons.sectionImage(to: cell, with: image, size: size, radius: radius)
				} else {
					SectionIcons.sectionImage(to: cell, with: UIImage(named: "unknown")!, size: size, radius: radius)
				}
			} else {
				SectionIcons.sectionImage(to: cell, with: UIImage(named: "unknown")!, size: size, radius: radius)
			}
			
		}
		
		cell.configure(with: source!, filePath: filePath!)
			
		
		return cell
	}

	
	func loadImage(from iconUrl: URL?) -> UIImage? {
		guard let iconUrl = iconUrl else { return nil }
		return UIImage(contentsOfFile: iconUrl.path)
	}

	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		switch segmentedControl.selectedSegmentIndex {
		case 0:
			break
		case 1:
			break
		default:
			break
		}
		
		tableView.deselectRow(at: indexPath, animated: true)
	}
	
	func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		
		var source: NSManagedObject?
		var path = ""
		switch self.segmentedControl.selectedSegmentIndex {
		case 0:
			source = self.downlaodedApps?[indexPath.row]
			path = "Unsigned"
		case 1:
			source = self.signedApps?[indexPath.row]
			path = "Signed"
		default:
			break
		}
		
		let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completionHandler) in
			do {
				if let uuid = source!.value(forKey: "uuid") as? String {
					let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
					let a = documentsDirectory
						.appendingPathComponent("Apps")
						.appendingPathComponent(path)
						.appendingPathComponent(uuid)
					try FileManager.default.removeItem(at: a)
				}
			} catch {
				print("Error deleting dir: \(error.localizedDescription)")
			}
			
			self.context.delete(source!)
			
			do {
				try self.context.save()
				
				switch self.segmentedControl.selectedSegmentIndex {
				case 0:
					self.downlaodedApps?.remove(at: indexPath.row)
				case 1:
					self.signedApps?.remove(at: indexPath.row)
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
			case 1:
				let fetchRequest: NSFetchRequest<SignedApps> = SignedApps.fetchRequest()
				let sortDescriptor = NSSortDescriptor(key: "dateAdded", ascending: false)
				fetchRequest.sortDescriptors = [sortDescriptor]
				self.signedApps = try context.fetch(fetchRequest)
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
}
