//
//  ViewController.swift
//  feather
//
//  Created by samara on 5/17/24.
//

import UIKit
import Nuke

class SourcesViewController: UITableViewController {
	
	public lazy var emptyStackView = EmptyPageStackView()
	
	let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
	var sources: [Source]?
	
	var isSelectMode: Bool = false {
		didSet {
			tableView.allowsMultipleSelection = isSelectMode
			setupNavigation()
		}
	}
	
	lazy var addButton = addAddButtonToView()
	
	init() { super.init(style: .plain) }
	required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupNavigation()
		setupViews()
		fetchSources()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(true)
	}
	
	fileprivate func setupViews() {
		self.tableView.backgroundColor = UIColor(named: "Background")
		self.tableView.dataSource = self
		self.tableView.delegate = self
		self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
		
		emptyStackView.title = "No Sources"
		emptyStackView.text = "Configure your source list by pressing \n\"+\" and adding an Altstore repository."
		emptyStackView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(emptyStackView)
		
		NSLayoutConstraint.activate([
			emptyStackView.centerXAnchor.constraint(equalTo: view.layoutMarginsGuide.centerXAnchor),
			emptyStackView.centerYAnchor.constraint(equalTo: view.layoutMarginsGuide.centerYAnchor, constant: -50),
		])
		
		self.makeAddButtonMenu()
		view.addSubview(addButton)
		NSLayoutConstraint.activate([
			addButton.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -20),
			addButton.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: -10),
			addButton.widthAnchor.constraint(equalToConstant: 45),
			addButton.heightAnchor.constraint(equalToConstant: 45)
		])
				
		self.refreshControl = UIRefreshControl()
		self.refreshControl?.addTarget(self, action: #selector(beginRefresh(_:)), for: .valueChanged)
		self.tableView.refreshControl = refreshControl
	}
	
	@objc func beginRefresh(_ sender: Any) {
		refreshControl?.endRefreshing()
	}
	
	fileprivate func setupNavigation() {
		self.navigationController?.navigationBar.prefersLargeTitles = true
		self.navigationItem.largeTitleDisplayMode = .always
		var leftBarButtonItems: [UIBarButtonItem] = []
//		var rightBarButtonItems: [UIBarButtonItem] = []
		
		if !isSelectMode {
//			let a = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .done, target: self, action: #selector(sourcesAddButtonTapped))
//			rightBarButtonItems.append(a)
//			let e = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(setEditingButton))
//			leftBarButtonItems.append(e)
		} else {
			let d = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneEditingButton))
			leftBarButtonItems.append(d)
		}
		
		navigationItem.leftBarButtonItems = leftBarButtonItems
//		navigationItem.rightBarButtonItems = rightBarButtonItems
	}
	
	func makeAddButtonMenu() {
		let pasteMenu = UIMenu(title: "", options: .displayInline, children: [
			UIAction(title: "Import from iCloud Drive", handler: { _ in
				print("Import from iCloud Drive")
			}),
			UIAction(title: "Import from Clipboard", handler: { _ in
				print("Import from Clipboard")
			})
		])

		let configuration = UIMenu(title: "", children: [
			UIAction(title: "Add Batch Sources", handler: { _ in
				print("Add Batch Sources")
			}),
			UIAction(title: "Add Source", handler: { _ in
				self.sourcesAddButtonTapped()
			}),
			pasteMenu
		])
		
		
		addButton.menu = configuration
		addButton.showsMenuAsPrimaryAction = true
	}
}

// MARK: - Tabelview
extension SourcesViewController {
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return sources?.count ?? 0 }
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
		
		let source = sources![indexPath.row]

		cell.textLabel?.text = source.name ?? "Unknown"
		cell.detailTextLabel?.text = source.sourceURL?.absoluteString
		cell.detailTextLabel?.textColor = .secondaryLabel
		cell.accessoryType = .disclosureIndicator
		cell.backgroundColor = UIColor(named: "Background")
		
//		print(source.apps?.count ?? 0)
		
		SectionIcons.sectionImage(to: cell, with: UIImage(named: "unknown")!)
		if let thumbnailURL = source.iconURL {
			let request = ImageRequest(url: thumbnailURL)

			if let cachedImage = ImagePipeline.shared.cache.cachedImage(for: request)?.image {
				SectionIcons.sectionImage(to: cell, with: cachedImage)
			} else {
				ImagePipeline.shared.loadImage(
					with: request,
					progress: nil,
					completion: { result in
						switch result {
						case .success(let imageResponse):
							DispatchQueue.main.async {
								SectionIcons.sectionImage(to: cell, with: imageResponse.image)
								tableView.reloadRows(at: [indexPath], with: .none)
							}
						case .failure(let error):
							print("Image loading failed with error: \(error)")
						}
					}
				)
			}
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
			
			self.context.delete(sourceToRm)
			
			do {
				try self.context.save()
				self.sources?.remove(at: indexPath.row)
				self.tableView.deleteRows(at: [indexPath], with: .automatic)
			} catch {
				print("error-Deleting data")
			}
			self.checkIfIshouldShow(source: self.sources!)
			completionHandler(true)
		}
		deleteAction.backgroundColor = UIColor.red

		let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
		configuration.performsFirstActionWithFullSwipe = true

		return configuration
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		guard let source = sources?[indexPath.row] as? Source else {
			print("Failed to retrieve source data.")
			return
		}

		if let sourceAppsSet = source.apps {
			let sourceAppsArray = sourceAppsSet.compactMap { $0 as? StoreApps }
			let sortedAppsArray = sourceAppsArray.sorted { $0.name! < $1.name! }

			let savc = SourceAppViewController()
			savc.name = source.name
			savc.apps = sortedAppsArray
			navigationController?.pushViewController(savc, animated: true)
		} else {
			print("No apps found for the selected source.")
		}
		tableView.deselectRow(at: indexPath, animated: true)
	}
	
	override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		if let count = sources?.count {
			
			if count == 0 {
				return nil
			} else {
				return "\(count) Sources"
			}
		}
		return nil
	}






	
}

// MARK: - Edit
extension SourcesViewController {
	@objc func doneEditingButton() { setEditing(false, animated: true) }
	@objc func setEditingButton() { setEditing(true, animated: true) }
	override func setEditing(_ editing: Bool, animated: Bool) {
		super.setEditing(editing, animated: animated)
		isSelectMode = editing
		tableView.setEditing(editing, animated: true)
		tableView.allowsMultipleSelection = false
	}
}
