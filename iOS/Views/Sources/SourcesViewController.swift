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

	var sources: [Source] = []
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
		self.title = String.localized("TAB_SOURCES")
	}
}

// MARK: - Tabelview
extension SourcesViewController {
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch section {
		case 0:
			return 1
		case 1:
			return sources.count
		default:
			return 0
		}
	}
	
	override func numberOfSections(in tableView: UITableView) -> Int { return 2 }
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { return 70 }
	
	override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		if section == 1 {
			let headerWithButton = GroupedSectionHeader(
				title: String.localized("SOURCES_VIEW_CONTROLLER_REPOSITORIES"),
				subtitle: String.localized(sources.count > 1 ? "SOURCES_VIEW_CONTROLLER_NUMBER_OF_SOURCES_PLURAL" : "SOURCES_VIEW_CONTROLLER_NUMBER_OF_SOURCES", arguments: "\(sources.count)"),
				buttonTitle: String.localized("SOURCES_VIEW_CONTROLLER_ADD_SOURCES"), buttonAction: {
					let transferPreview = RepoViewController(sources: self.sources)
					
					let hostingController = UIHostingController(rootView: transferPreview)
					hostingController.modalPresentationStyle = .formSheet
					
					if let presentationController = hostingController.presentationController as? UISheetPresentationController {
						presentationController.detents = [.medium()]
					}
					
					DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
						self.present(hostingController, animated: true)
					}
				})
			
			return headerWithButton
		} else {
			return nil
		}
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
		
		cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 17)
		cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 13)
		cell.detailTextLabel?.textColor = .secondaryLabel
		cell.accessoryType = .disclosureIndicator
		cell.backgroundColor = .clear

		switch indexPath.section {
		case 0:
			cell.textLabel?.text = "All Repositories"
			cell.detailTextLabel?.text = "See all apps from your sources"
			
			var repoIcon = "books.vertical.fill"
			if #available(iOS 16.0, *) { repoIcon = "globe.desk.fill" }
			
			SectionIcons.sectionIcon(to: cell, with: repoIcon, backgroundColor: Preferences.appTintColor.uiColor.withAlphaComponent(0.7))
			return cell
		case 1:
			if sources.isEmpty { return cell }
			let source = sources[indexPath.row]
			
			cell.textLabel?.text = source.name ?? String.localized("UNKNOWN")
			
			if source.identifier == "kh.crysalis.feather-repo.beta" {
				cell.detailTextLabel?.text = "Thank you for donating!"
			} else {
				cell.detailTextLabel?.text = source.sourceURL?.absoluteString
			}
			
			if let thumbnailURL = source.iconURL {
				SectionIcons.loadSectionImageFromURL(from: thumbnailURL, for: cell, at: indexPath, in: tableView)
			} else {
				SectionIcons.sectionImage(to: cell, with: UIImage(named: "unknown")!)
			}
			return cell
		default:
			break
		}

		return cell
	}

	override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		if indexPath.section == 1 {
			let source = sources[indexPath.row]
			
			let configuration = UIContextMenuConfiguration(identifier: nil, actionProvider: { _ in
				return UIMenu(title: "", image: nil, identifier: nil, options: [], children: [
					UIAction(title: String.localized("COPY"), image: UIImage(systemName: "doc.on.clipboard"), handler: {_ in
						if source.identifier == "kh.crysalis.feather-repo.beta" {
							UIPasteboard.general.string = "Thank you for donating!"
						} else {
							UIPasteboard.general.string = source.sourceURL?.absoluteString
						}
					})
				])
			})
			return configuration
		} else {
			return nil
		}
	}

	override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		if indexPath.section == 1 {
			let deleteAction = UIContextualAction(style: .destructive, title: String.localized("DELETE")) { (action, view, completionHandler) in
				let sourceToRm = self.sources[indexPath.row]
				CoreDataManager.shared.context.delete(sourceToRm)
				do {
					try CoreDataManager.shared.context.save()
					self.sources.remove(at: indexPath.row)
					self.searchResultsTableViewController.sources = self.sources
					self.tableView.reloadSections(IndexSet(integer: 1), with: .automatic)
				} catch {
					Debug.shared.log(message: "trailingSwipeActionsConfigurationForRowAt.deleteAction", type: .error)
				}
				completionHandler(true)
			}
			deleteAction.backgroundColor = UIColor.red
			
			let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
			configuration.performsFirstActionWithFullSwipe = true
			
			return configuration
		} else {
			return nil
		}
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if sources.isEmpty {
			tableView.deselectRow(at: indexPath, animated: true)
			return
		}
		
		let sourcerow = sources[indexPath.row]
		
		switch indexPath.section {
		case 0:
			let savc = SourceAppViewController()
			savc.name = "All Repositories"
			savc.uri = sources.compactMap { $0.sourceURL }
			navigationController?.pushViewController(savc, animated: true)
		case 1:
			let savc = SourceAppViewController()
			savc.name = sourcerow.name
			if let sourceURL = sourcerow.sourceURL {
				savc.uri = [sourceURL]
			}
			navigationController?.pushViewController(savc, animated: true)
		default:
			break
		}
		
		tableView.deselectRow(at: indexPath, animated: true)
	}

}

extension SourcesViewController {
	@objc func fetch() {self.fetchSources()}
	func fetchSources() {
		sources = CoreDataManager.shared.getAZSources()
		searchResultsTableViewController.sources = sources
		DispatchQueue.main.async {
			self.tableView.reloadSections(IndexSet(integer: 1), with: .automatic)
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
		searchResultsTableViewController.sources = sources
		self.navigationItem.searchController = searchController
		self.definesPresentationContext = true
		self.navigationItem.hidesSearchBarWhenScrolling = false
	}
}

