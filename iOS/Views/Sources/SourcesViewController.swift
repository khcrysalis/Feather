//
//  ViewController.swift
//  feather
//
//  Created by samara on 5/17/24.
//  Copyright (c) 2024 Samara M (khcrysalis)
//

import UIKit
import Nuke
import CoreData
import SwiftUI

class SourcesViewController: UITableViewController {

	var sources: [Source]?
	public var searchController: UISearchController!
	let searchResultsTableViewController = SearchResultsTableViewController()

	init() { super.init(style: .grouped) }
	required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

	override func viewDidLoad() {
		super.viewDidLoad()
		setupViews()
		setupSearchController()
		fetchSources()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		setupNavigation()
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
	}

	fileprivate func setupViews() {
		self.tableView.dataSource = self
		
		self.tableView.delegate = self
		self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
		self.tableView.refreshControl = refreshControl
		NotificationCenter.default.addObserver(self, selector: #selector(fetch), name: Notification.Name("sfetch"), object: nil)
	}
	
	deinit {
		NotificationCenter.default.removeObserver(self, name: Notification.Name("sfetch"), object: nil)
	}

	fileprivate func setupNavigation() {
		self.navigationController?.navigationBar.prefersLargeTitles = true
		self.navigationItem.largeTitleDisplayMode = .always
	}
	
	@objc func openSettings() {
		let settings = SettingsViewController()
		
		let navigationController = UINavigationController(rootViewController: settings)
		let detent2: UISheetPresentationController.Detent = ._detent(withIdentifier: "Test2", constant: 200.0)
		
		if let presentationController = navigationController.presentationController as? UISheetPresentationController {
			presentationController.detents = [
				detent2,
				.large(),
				
			]
		}

		self.present(navigationController, animated: true)
	}
}

// MARK: - Tabelview
extension SourcesViewController {
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return sources?.count ?? 0 }
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { return 70 }
	override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		//String.localized("SOURCES_VIEW_CONTROLLER_NUMBER_OF_SOURCES", arguments: (sources?.count ?? 0))
		let headerWithButton = GroupedSectionHeader(
			title: String.localized("SOURCES_VIEW_CONTROLLER_REPOSITORIES"),
			subtitle: String.localized("SOURCES_VIEW_CONTROLLER_NUMBER_OF_SOURCES", arguments: "\(sources?.count ?? 0)"),
			buttonTitle: "Modify", buttonAction: {
				
				let transferPreview = RepoViewController(sources: self.sources)
				
				let hostingController = UIHostingController(rootView: transferPreview)
				hostingController.modalPresentationStyle = .pageSheet
				
				if let presentationController = hostingController.presentationController as? UISheetPresentationController {
					presentationController.detents = [.medium()]
				}
				
				DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
					self.present(hostingController, animated: true)
				}
				
				
//			self.sourcesAddButtonTapped()
		})
		return headerWithButton
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")

		let source = sources![indexPath.row]

		cell.textLabel?.text = source.name ?? String.localized("UNKNOWN")
		cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 17)
		cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 13)
		cell.detailTextLabel?.text = source.sourceURL?.absoluteString
		cell.detailTextLabel?.textColor = .secondaryLabel
		cell.accessoryType = .disclosureIndicator
		cell.backgroundColor = .clear

		if let thumbnailURL = source.iconURL {
			SectionIcons.loadSectionImageFromURL(from: thumbnailURL, for: cell, at: indexPath, in: tableView)
		} else {
			SectionIcons.sectionImage(to: cell, with: UIImage(named: "unknown")!)
		}
		return cell
	}

	override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		let source = sources![indexPath.row]

		let configuration = UIContextMenuConfiguration(identifier: nil, actionProvider: { _ in
			return UIMenu(title: "", image: nil, identifier: nil, options: [], children: [
				UIAction(title: String.localized("COPY"), image: UIImage(systemName: "doc.on.clipboard"), handler: {_ in
					UIPasteboard.general.string = source.sourceURL?.absoluteString
				})
			])
		})
		return configuration
	}

	override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		let deleteAction = UIContextualAction(style: .destructive, title: String.localized("DELETE")) { (action, view, completionHandler) in
			let sourceToRm = self.sources![indexPath.row]
			CoreDataManager.shared.context.delete(sourceToRm)
			do {
				try CoreDataManager.shared.context.save()
				self.sources?.remove(at: indexPath.row)
				self.searchResultsTableViewController.sources = self.sources ?? []
				self.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
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
		guard let sourcerow = sources?[indexPath.row] else { return }
		let savc = SourceAppViewController()
		savc.name = sourcerow.name
		savc.uri = sourcerow.sourceURL
		navigationController?.pushViewController(savc, animated: true)
		tableView.deselectRow(at: indexPath, animated: true)
	}
}

extension SourcesViewController {
	@objc func fetch() {self.fetchSources()}
	func fetchSources() {
		sources = CoreDataManager.shared.getAZSources()
		searchResultsTableViewController.sources = sources ?? []
		DispatchQueue.main.async {
			self.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
		}
	}
}

extension SourcesViewController: UISearchControllerDelegate, UISearchBarDelegate {
	func setupSearchController() {
		self.searchController = UISearchController(searchResultsController: searchResultsTableViewController)
		self.searchController.obscuresBackgroundDuringPresentation = true
		self.searchController.hidesNavigationBarDuringPresentation = true
		self.searchController.delegate = self
		self.searchController.searchBar.placeholder = String.localized("SOURCES_VIEW_CONTROLLER_SEARCH_SOURCES")
		self.searchController.searchResultsUpdater = searchResultsTableViewController
		searchResultsTableViewController.sources = sources ?? []
		self.navigationItem.searchController = searchController
		self.definesPresentationContext = true
		self.navigationItem.hidesSearchBarWhenScrolling = false
	}
}

