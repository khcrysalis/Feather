//
//  ViewController.swift
//  feather
//
//  Created by samara on 5/17/24.
//

import UIKit
import Nuke
import CoreData

class SourcesViewController: UITableViewController {

	var sources: [Source]?

	init() { super.init(style: .plain) }
	required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

	override func viewDidLoad() {
		super.viewDidLoad()
		setupNavigation()
		setupViews()
		fetchSources()
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
	}

	fileprivate func setupViews() {
		self.tableView.dataSource = self
		self.tableView.delegate = self
		self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
		self.refreshControl = UIRefreshControl()
		self.refreshControl?.addTarget(self, action: #selector(beginRefresh(_:)), for: .valueChanged)
		self.tableView.refreshControl = refreshControl
		NotificationCenter.default.addObserver(self, selector: #selector(fetch), name: Notification.Name("sfetch"), object: nil)
	}
	
	deinit {
		NotificationCenter.default.removeObserver(self, name: Notification.Name("sfetch"), object: nil)
	}

	@objc func beginRefresh(_ sender: Any) {
		CoreDataManager.shared.refreshSources() {_ in 
			self.refreshControl?.endRefreshing()
		}
	}

	fileprivate func setupNavigation() {
		self.navigationController?.navigationBar.prefersLargeTitles = true
		self.navigationItem.largeTitleDisplayMode = .always
		var leftBarButtonItems: [UIBarButtonItem] = []
		var rightBarButtonItems: [UIBarButtonItem] = []
		
		let configuration = UIMenu(title: "", children: [
			UIAction(title: "Add Source", handler: { _ in
				self.sourcesAddButtonTapped()
			}),
		])

		
		let addButton = UIBarButtonItem(image: UIImage(systemName: "plus"), menu: configuration)
		rightBarButtonItems.append(addButton)

		navigationItem.leftBarButtonItems = leftBarButtonItems
		navigationItem.rightBarButtonItems = rightBarButtonItems
	}
}

// MARK: - Tabelview
extension SourcesViewController {
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return sources?.count ?? 0 }
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { return 70 }
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")

		let source = sources![indexPath.row]

		cell.textLabel?.text = source.name ?? "Unknown"
		cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 17)
		cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 13)
		cell.detailTextLabel?.text = source.sourceURL?.absoluteString
		cell.detailTextLabel?.textColor = .secondaryLabel
		cell.accessoryType = .disclosureIndicator

		if let thumbnailURL = source.iconURL {
			SectionIcons.loadImageFromURL(from: thumbnailURL, for: cell, at: indexPath, in: tableView)
		} else if let appsSet = source.apps as? Set<StoreApps> {
			let sortedApps = CoreDataManager.shared.getAZStoreApps(from: appsSet)
			if let firstApp = sortedApps.first,
			   let firstAppIconURL = firstApp.iconURL {
				SectionIcons.loadImageFromURL(from: firstAppIconURL, for: cell, at: indexPath, in: tableView)
			} else {
				SectionIcons.sectionImage(to: cell, with: UIImage(named: "unknown")!)
			}
		} else {
			SectionIcons.sectionImage(to: cell, with: UIImage(named: "unknown")!)
		}




		return cell
	}

	override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		let source = sources![indexPath.row]

		let configuration = UIContextMenuConfiguration(identifier: nil, actionProvider: { _ in
			return UIMenu(title: "", image: nil, identifier: nil, options: [], children: [
				UIAction(title: "Copy", image: UIImage(systemName: "doc.on.clipboard"), handler: {_ in
					UIPasteboard.general.string = source.sourceURL?.absoluteString
				})
			])
		})
		return configuration
	}

	override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completionHandler) in
			let sourceToRm = self.sources![indexPath.row]
			CoreDataManager.shared.context.delete(sourceToRm)
			do {
				try CoreDataManager.shared.context.save()
				self.sources?.remove(at: indexPath.row)
				self.tableView.deleteRows(at: [indexPath], with: .automatic)
			} catch {
				Debug.shared.log(message: "trailingSwipeActionsConfigurationForRowAt.deleteAction", type: .error)
			}
			completionHandler(true)
		}
		deleteAction.backgroundColor = UIColor.red

		let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
		configuration.performsFirstActionWithFullSwipe = true

		return configuration
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		guard let sourcerow = sources?[indexPath.row] else {
			return
		}

		if let sourceAppsSet = sourcerow.apps {
			let sourceAppsArray = sourceAppsSet.compactMap { $0 as? StoreApps }
			let sortedAppsArray = sourceAppsArray.sorted { $0.name! < $1.name! }

			let savc = SourceAppViewController()
			savc.name = sourcerow.name
			savc.apps = sortedAppsArray
			navigationController?.pushViewController(savc, animated: true)
		}

		tableView.deselectRow(at: indexPath, animated: true)
	}
}

extension SourcesViewController {
	@objc func fetch() {self.fetchSources()}
	func fetchSources() {
		sources = CoreDataManager.shared.getAZSources()
		DispatchQueue.main.async {
			self.tableView.reloadData()
		}
	}
}


