//
//  SourceAppViewController.swift
//  feather
//
//  Created by samara on 5/22/24.
//  Copyright (c) 2024 Samara M (khcrysalis)
//

import UIKit
import Nuke
import AlertKit
import CoreData
import SwiftUI

enum SortOption: String, Codable {
	case `default`
	case name
	case date
}

class SourceAppViewController: UITableViewController {
	var newsData: [NewsData] = []
	var apps: [StoreAppsData] = []
	var oApps: [StoreAppsData] = []
	var filteredApps: [StoreAppsData] = []
	
	var name: String? { didSet { self.title = name } }
	var uri: [URL]!
	
	
	var highlightAppName: String?
	var highlightBundleID: String?
	var highlightVersion: String?
	var highlightDeveloperName: String?
	var highlightDescription: String?
	
	var sortActionsGroup: UIMenu?
	
	private let sourceGET = SourceGET()
	
	public var searchController: UISearchController!
	
	private let activityIndicator: UIActivityIndicatorView = {
		let indicator = UIActivityIndicatorView(style: .medium)
		indicator.hidesWhenStopped = true
		return indicator
	}()
	
	init() { super.init(style: .plain) }
	required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupNavigation()
		setupSearchController()
		setupViews()
		loadAppsData()
	}
	
	fileprivate func setupViews() {
		self.tableView.dataSource = self
		self.tableView.delegate = self
		self.tableView.tableHeaderView = UIView()
		self.tableView.register(AppTableViewCell.self, forCellReuseIdentifier: "AppTableViewCell")
		self.navigationItem.titleView = activityIndicator
		self.activityIndicator.startAnimating()
	}
	
	private func setupHeader() {
		if uri.count == 1 && newsData != [] {
			let headerView = UIHostingController(rootView: NewsCardsScrollView(newsData: newsData))
			headerView.view.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 170)
			tableView.tableHeaderView = headerView.view
			
			addChild(headerView)
			headerView.didMove(toParent: self)
		}
	}
	
	private func updateFilterMenu() {
		let filterMenu = UIMenu(title: String.localized("SOURCES_CELLS_ACTIONS_FILTER_TITLE"), children: createSubSortMenu())
		let filterButton = UIBarButtonItem(image: UIImage(systemName: "line.3.horizontal.decrease"), menu: filterMenu)
		
		self.navigationItem.rightBarButtonItem = filterButton
	}
	
	private func createSubSortMenu() -> [UIMenuElement] {
		let sortByDAction = createSortAction(title: String.localized("SOURCES_CELLS_ACTIONS_FILTER_BY_DEFAULT"), sortOption: .default)
		let sortByNameAction = createSortAction(title: String.localized("SOURCES_CELLS_ACTIONS_FILTER_BY_NAME"), sortOption: .name)
		let sortBySizeAction = createSortAction(title: String.localized("SOURCES_CELLS_ACTIONS_FILTER_BY_DATE"), sortOption: .date)
		
		let meowMenu = UIMenu(title: "",
							  image: nil,
							  identifier: nil,
							  options: .displayInline,
							  children: [sortByDAction, sortByNameAction, sortBySizeAction])
		
		return [meowMenu]
	}

	
	func applyFilter() {
		let sortOption = Preferences.currentSortOption
		let ascending = Preferences.currentSortOptionAscending
		
		switch sortOption {
		case .default:
			apps = ascending ? oApps : oApps.reversed()
		case .name:
			apps = apps.sorted { ascending ? $0.name < $1.name : $0.name > $1.name }
		case .date:
			apps = apps.sorted {
				let date0 = $0.versions?.first?.date ?? $0.versionDate
				let date1 = $1.versions?.first?.date ?? $1.versionDate
				
				if date0 == nil && date1 == nil { return ascending }
				
				guard let date0 = date0, let date1 = date1 else {
					return date0 != nil
				}
				
				return ascending ? date0 > date1 : date0 < date1
			}
		}
		
		UIView.transition(with: tableView, duration: 0.3, options: .transitionCrossDissolve, animations: {
			self.tableView.reloadData()
		}, completion: nil)
		
		updateFilterMenu()
	}

	
	private func createSortAction(title: String, sortOption: SortOption) -> UIAction {
		return UIAction(title: title,
						image: arrowImage(for: sortOption),
						identifier: UIAction.Identifier("sort\(title)"),
						state: Preferences.currentSortOption == sortOption ? .on : .off,
						handler: { [weak self] _ in
			guard let self = self else { return }
			
			if Preferences.currentSortOption == sortOption {
				Preferences.currentSortOptionAscending.toggle()
			} else {
				Preferences.currentSortOption = sortOption
				updateSortOrderImage(for: sortOption)
			}
			applyFilter()
		})
	}
	
	/// Arrowimages for Sort options
	func arrowImage(for sortOption: SortOption) -> UIImage? {
		let isAscending = Preferences.currentSortOptionAscending
		let imageName = isAscending ? "chevron.up" : "chevron.down"
		return sortOption == Preferences.currentSortOption ? UIImage(systemName: imageName) : nil
	}
	
	func updateSortOrderImage(for sortOption: SortOption) {
		guard let sortActionsGroup = sortActionsGroup else {
			print("sortActionsGroup is nil")
			return
		}
		
		for case let action as UIAction in sortActionsGroup.children {
			if action.identifier == UIAction.Identifier("sort\(sortOption)") {
				if let image = arrowImage(for: sortOption) {
					action.image = image
				}
			}
		}
	}
	
	fileprivate func setupNavigation() {
		self.navigationItem.largeTitleDisplayMode = .never
	}
	
	private func loadAppsData() {
		guard let urls = uri else { return }
		let dispatchGroup = DispatchGroup()
		var allApps: [StoreAppsData] = []
		var newsData: [NewsData] = []
		
		var website = ""
		var tintColor = ""
		
		for uri in urls {
			dispatchGroup.enter()
			
			sourceGET.downloadURL(from: uri) { [weak self] result in
				switch result {
				case .success(let (data, _)):
					if let parseResult = self?.sourceGET.parse(data: data), case .success(let sourceData) = parseResult {
						allApps.append(contentsOf: sourceData.apps)
						newsData.append(contentsOf: sourceData.news ?? [])
						tintColor = sourceData.tintColor ?? ""
						website = sourceData.website ?? ""
					}
				case .failure(let error):
					Debug.shared.log(message: "Error fetching data from \(uri): \(error.localizedDescription)")
				}
				
				dispatchGroup.leave()
			}
		}
		
		dispatchGroup.notify(queue: .main) { [weak self] in
			self?.apps = allApps
			self?.oApps = allApps
			self?.newsData = newsData
			
			self?.setupHeader()
			
			if tintColor != "" {
				self?.view.tintColor = UIColor(hex: tintColor)
			}
						
			if let fil = self?.shouldFilter() {
				self?.apps = [fil].compactMap { $0 }
			} else {
				self?.applyFilter()
			}
			
			if self?.uri.count == 1 {
				let children = [
					UIAction(title: "Visit Website", image: UIImage(systemName: "globe")) { _ in
						UIApplication.shared.open(URL(string: website)!, options: [:], completionHandler: nil)
					}
				]
				
				let menu = UIMenu(children: children)
				
				if #available(iOS 16.0, *) {
					if (website != "") {
						self?.navigationItem.titleMenuProvider = { _ in
							menu
						}
					}
				}
			}
						
			UIView.transition(with: self!.tableView, duration: 0.3, options: .transitionCrossDissolve, animations: {
				self!.activityIndicator.stopAnimating()
				
				self?.navigationItem.titleView = nil
				if self?.highlightAppName == nil {
					self?.updateFilterMenu()
				}
				self?.tableView.reloadData()
			}, completion: nil)
		}
	}

	
	private func shouldFilter() -> StoreAppsData? {
		guard
			let name = highlightAppName,
			let id = highlightBundleID,
			let version = highlightVersion,
			let desc = highlightDescription
		else {
			return nil
		}
		
		return filterApps(from: apps, name: name, id: id, version: version, desc: desc, devname: highlightDeveloperName).first
	}

	private func filterApps(from apps: [StoreAppsData], name: String, id: String, version: String, desc: String, devname: String?) -> [StoreAppsData] {
		return apps.filter { app in
			return app.name == name &&
				   app.bundleIdentifier == id &&
				   app.version == version &&
				   app.localizedDescription == desc &&
				   (devname == nil || app.developerName == devname)
		}
	}

}

extension SourceAppViewController {
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return isFiltering ? filteredApps.count : apps.count
	}
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		let app = isFiltering ? filteredApps[indexPath.row] : apps[indexPath.row]
		if (app.screenshotURLs != nil), !app.screenshotURLs!.isEmpty, Preferences.appDescriptionAppearence != 2 {
			return 322
		} else if Preferences.appDescriptionAppearence == 2 {
			return UITableView.automaticDimension
		} else {
			return 72
		}
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = AppTableViewCell(style: .subtitle, reuseIdentifier: "RoundedBackgroundCell")
		let app = isFiltering ? filteredApps[indexPath.row] : apps[indexPath.row]
		cell.configure(with: app)
		cell.selectionStyle = .none
		cell.backgroundColor = .clear
		cell.getButton.tag = indexPath.row
		cell.getButton.addTarget(self, action: #selector(getButtonTapped(_:)), for: .touchUpInside)
		let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(getButtonHold(_:)))
		cell.getButton.addGestureRecognizer(longPressGesture)
		cell.getButton.longPressGestureRecognizer = longPressGesture
		return cell
	}
	
	override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		let app = isFiltering ? filteredApps[indexPath.row] : apps[indexPath.row]
		
		let configuration = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
			let versionActions = app.versions?.map { version in
				UIAction(
					title: "\(version.version)",
					image: UIImage(systemName: "doc.on.clipboard")
				) { _ in
					UIPasteboard.general.string = version.downloadURL.absoluteString
				}
			} ?? []
			
			let versionsMenu = UIMenu(
				title: "Other Download Links",
				image: UIImage(systemName: "list.bullet"),
				children: versionActions
			)
			
			let latestAction = UIAction(
				title: "Copy Latest Download Link",
				image: UIImage(systemName: "doc.on.clipboard")
			) { _ in
				UIPasteboard.general.string =
				app.downloadURL?.absoluteString
				?? app.versions?[0].downloadURL.absoluteString
			}
			
			return UIMenu(title: "", children: [latestAction, versionsMenu])
		}
		
		return configuration
	}

	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		if isFiltering || apps.isEmpty || (highlightAppName != nil) {
			return nil
		} else {
			//return "\(apps.count) Apps"
			return String.localized(apps.count > 1 ? "SOURCES_APP_VIEW_CONTROLLER_NUMBER_OF_APPS_PLURAL" : "SOURCES_APP_VIEW_CONTROLLER_NUMBER_OF_APPS", arguments: "\(apps.count)")
		}
	}
}

extension SourceAppViewController: UISearchControllerDelegate, UISearchBarDelegate {
	func setupSearchController() {
		searchController = UISearchController(searchResultsController: nil)
		searchController.obscuresBackgroundDuringPresentation = false
		searchController.hidesNavigationBarDuringPresentation = true
		searchController.searchResultsUpdater = self
		searchController.delegate = self
		searchController.searchBar.placeholder = String.localized("SOURCES_APP_VIEW_CONTROLLER_SEARCH_APPS")
		if (highlightAppName == nil) {
			navigationItem.searchController = searchController
			definesPresentationContext = true
			navigationItem.hidesSearchBarWhenScrolling = true
		}
	}
	
	var isFiltering: Bool {
		return searchController.isActive && !searchBarIsEmpty
	}

	var searchBarIsEmpty: Bool {
		return searchController.searchBar.text?.isEmpty ?? true
	}
}

extension SourceAppViewController: UISearchResultsUpdating {
	func updateSearchResults(for searchController: UISearchController) {
		let searchText = searchController.searchBar.text ?? ""
		filterContentForSearchText(searchText)
		tableView.reloadData()
	}
	
	private func filterContentForSearchText(_ searchText: String) {
		let lowercasedSearchText = searchText.lowercased()

		filteredApps = apps.filter { app in
			let nameMatch = app.name.lowercased().contains(lowercasedSearchText)
			let bundleIdentifierMatch = app.bundleIdentifier.lowercased().contains(lowercasedSearchText) 
			let developerNameMatch = app.developerName?.lowercased().contains(lowercasedSearchText) ?? false
			let subtitleMatch = app.subtitle?.lowercased().contains(lowercasedSearchText) ?? false
			let localizedDescriptionMatch = app.localizedDescription?.lowercased().contains(lowercasedSearchText) ?? false

			return nameMatch || bundleIdentifierMatch || developerNameMatch || subtitleMatch || localizedDescriptionMatch
		}
	}

}
