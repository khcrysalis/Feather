//
//  ViewController.swift
//  feather
//
//  Created by samara on 5/17/24.
//

import UIKit

class SourcesViewController: UIViewController {

	var tableView: UITableView!
	var sources: [Source] = []
	
	var isSelectMode: Bool = false {
		didSet {
			tableView.allowsMultipleSelection = isSelectMode
			setupNavigation()
		}
	}
	
	private var refreshControl: UIRefreshControl!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupNavigation()
		setupViews()
		fetchAndReloadSources()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(true)
	}
	
	fileprivate func setupViews() {
		self.tableView = UITableView(frame: .zero, style: .insetGrouped)
		self.tableView.translatesAutoresizingMaskIntoConstraints = false
		self.tableView.backgroundColor = UIColor(named: "Background")
		self.tableView.separatorStyle = .none
		self.tableView.dataSource = self
		self.tableView.delegate = self
		self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "RoundedBackgroundCell")
		
		self.view.addSubview(tableView)
		self.tableView.constraintCompletely(to: view)
		
		self.refreshControl = UIRefreshControl()
		self.refreshControl.addTarget(self, action: #selector(beginRefresh(_:)), for: .valueChanged)
		self.tableView.refreshControl = refreshControl
	}
	
	fileprivate func setupNavigation() {
		self.navigationController?.navigationBar.prefersLargeTitles = true
		var leftBarButtonItems: [UIBarButtonItem] = []
		var rightBarButtonItems: [UIBarButtonItem] = []
		
		if !isSelectMode {
			let a = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .done, target: self, action: #selector(sourcesAddButtonTapped))
			rightBarButtonItems.append(a)
//			let e = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(setEditingButton))
//			leftBarButtonItems.append(e)
		} else {
			let d = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneEditingButton))
			leftBarButtonItems.append(d)
		}
		
		navigationItem.leftBarButtonItems = leftBarButtonItems
		navigationItem.rightBarButtonItems = rightBarButtonItems
	}
	
	@objc func sourcesAddButtonTapped() {
		RepoManager().addSource(from: "https://cdn.altstore.io/file/altstore/apps.json")
		self.refreshRepos()
	}
	
	func fetchAndReloadSources() {
		sources = RepoManager().listLocalSources()
		tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
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

// MARK: - Table View Delegates
extension SourcesViewController: UITableViewDelegate, UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return sources.count }
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		// I may just revert to a standard cell .
		let cell = SourcesTableViewCell(style: .subtitle, reuseIdentifier: "RoundedBackgroundCell")
		
		cell.selectionStyle = .none
		if indexPath.row % 2 == 0 {
			cell.contentView.backgroundColor = .clear
		} else {
			cell.contentView.backgroundColor = UIColor(named: "Cells")
		}
		
		let source = sources[indexPath.row]
		let sourceURL = RepoManager().fetchLocalURL(for: source)?.absoluteString
		cell.textLabel?.text = source.name ?? sourceURL
		cell.detailTextLabel?.text = sourceURL
		cell.detailTextLabel?.textColor = .secondaryLabel
		
		let iconImage = RepoManager().fetchIconImage(for: source)
		SectionIcons.sectionImage(to: cell, with: iconImage)
		
		return cell
	}
	
	func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		let source = sources[indexPath.row]
		let sourceURL = RepoManager().fetchLocalURL(for: source)?.absoluteString

		let configuration = UIContextMenuConfiguration(identifier: nil, actionProvider: { _ in
			return UIMenu(title: "", image: nil, identifier: nil, options: [], children: [
				UIAction(title: "Copy", image: UIImage(systemName: "doc.on.clipboard"), handler: {_ in
					UIPasteboard.general.string = sourceURL!
				})
			])
		})
		return configuration
	}
	
	func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		// Create a delete action
		let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completionHandler) in
			// Handle the delete action
			self.removeRepo(at: indexPath)
			completionHandler(true)
		}
		deleteAction.backgroundColor = UIColor.red

		// Create a swipe actions configuration
		let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
		configuration.performsFirstActionWithFullSwipe = true

		return configuration
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let source = sources[indexPath.row]
		print(source.identifier)
		tableView.deselectRow(at: indexPath, animated: true)
	}
}
// MARK: - Refresh
extension SourcesViewController {
	@objc func beginRefresh(_ sender: AnyObject) { self.refreshRepos() }
	func refreshRepos() {
		self.refreshControl?.beginRefreshing()
		let sources = RepoManager().listLocalSources()
		let group = DispatchGroup()
		let repoManager = RepoManager()
		repoManager.refreshSources(sources: sources, group: group)
		
		group.notify(queue: .main) {
			self.fetchAndReloadSources()
			self.refreshControl?.endRefreshing()
		}
	}
	
	func removeRepo(at indexPath: IndexPath) {
		let source = sources[indexPath.row]

		let repoManager = RepoManager()
		repoManager.deleteSource(with: source.identifier)
		
		DispatchQueue.main.async {
			self.sources.remove(at: indexPath.row)
			self.tableView.deleteRows(at: [indexPath], with: .automatic)
			self.tableView.reloadData()
		}
	}
}
