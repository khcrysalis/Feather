//
//  SourceAppsTableView.swift
//  Feather
//
//  Created by samara on 3.05.2025.
//

import SwiftUI
import AltSourceKit

// MARK: - Representable
struct SourceAppsTableRepresentableView: UIViewRepresentable {
	var sources: [ASRepository]
	@Binding var searchText: String
	@Binding var sortOption: SourceAppsView.SortOption
	@Binding var sortAscending: Bool
	
	func makeUIView(context: Context) -> UITableView {
		let tableView = UITableView(frame: .zero, style: .plain)
		tableView.delegate = context.coordinator
		tableView.dataSource = context.coordinator
		tableView.register(UITableViewCell.self, forCellReuseIdentifier: "AppCell")
		tableView.register(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: "SectionHeader")
		tableView.allowsSelection = false
		
		if let firstSource = sources.first, sources.count == 1 {
			let header = UIHostingController(rootView: SourceNewsView(news: firstSource.news))
			header.view.translatesAutoresizingMaskIntoConstraints = true
			header.view.backgroundColor = .clear
			let targetSize = header.view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
			header.view.frame = CGRect(origin: .zero, size: targetSize)
			tableView.tableHeaderView = header.view
		}
		
		tableView.alpha = 0
		
		if let firstSource = sources.first, sources.count == 1 {
			let header = UIHostingController(rootView: SourceNewsView(news: firstSource.news))
			header.view.translatesAutoresizingMaskIntoConstraints = true
			header.view.backgroundColor = .clear
		}
		
		UIView.transition(with: tableView,  duration: 0.3, options: [.transitionCrossDissolve], animations: {
			tableView.alpha = 1
		}, completion: nil)
		
		return tableView
	}
	
	func updateUIView(_ tableView: UITableView, context: Context) {
		context.coordinator.uiTableView = tableView
		
		let sourcesChanged = context.coordinator.sources != sources
		let searchChanged = context.coordinator.searchText != searchText
		let sortOptionChanged = context.coordinator.sortOption != sortOption
		let sortDirectionChanged = context.coordinator.sortAscending != sortAscending
		
		context.coordinator.sources = sources
		context.coordinator.searchText = searchText
		context.coordinator.sortOption = sortOption
		context.coordinator.sortAscending = sortAscending
		
		if sourcesChanged || searchChanged || sortOptionChanged || sortDirectionChanged {
			context.coordinator.invalidateCache()
		}
	}
	
	func makeCoordinator() -> Coordinator {
		Coordinator(
			sources: sources,
			searchText: searchText,
			sortOption: sortOption,
			sortAscending: sortAscending
		)
	}
}

// MARK: - Representable Extension: Coordinator
extension SourceAppsTableRepresentableView { class Coordinator: NSObject, UITableViewDataSource, UITableViewDelegate {
	var sources: [ASRepository]
	var searchText: String
	var sortOption: SourceAppsView.SortOption
	var sortAscending: Bool
	
	private var groupedAppsByNameFirstLetter: [String: [(source: ASRepository, app: ASRepository.App)]] = [:]
	private var groupedAppsByDate: [String: [(source: ASRepository, app: ASRepository.App)]] = [:]
	private var sortedSectionTitles: [String] = []
	
	private var cachedSortedApps: [(source: ASRepository, app: ASRepository.App)] = []
	weak var uiTableView: UITableView?
	
	private var allAppsWithSource: [(source: ASRepository, app: ASRepository.App)] {
		sources.flatMap { source in source.apps.map { (source: source, app: $0) } }
	}
	
	private var _sortedApps: [(source: ASRepository, app: ASRepository.App)] {
		if !cachedSortedApps.isEmpty {
			return cachedSortedApps
		}
		cachedSortedApps = calculateSortedApps()
		return cachedSortedApps
	}
	
	init(sources: [ASRepository], searchText: String, sortOption: SourceAppsView.SortOption, sortAscending: Bool) {
		self.sources = sources
		self.searchText = searchText
		self.sortOption = sortOption
		self.sortAscending = sortAscending
		super.init()
	}
	
	private func calculateSortedApps() -> [(source: ASRepository, app: ASRepository.App)] {
		let filtered = allAppsWithSource.filter {
			searchText.isEmpty || ($0.app.name?.localizedCaseInsensitiveContains(searchText) ?? false)
		}
		
		switch sortOption {
		case .default:
			groupedAppsByDate = [:]
			groupedAppsByNameFirstLetter = [:]
			sortedSectionTitles = []
			return sortAscending ? filtered : filtered.reversed()
		case .date:
			let sorted = filtered.sorted {
				let d1 = $0.app.currentDate?.date ?? .distantPast
				let d2 = $1.app.currentDate?.date ?? .distantPast
				return sortAscending ? (d1 < d2) : (d1 > d2)
			}
			
			let formatter = DateFormatter()
			formatter.dateFormat = "MMMM d, yyyy"
			
			let grouped = Dictionary(grouping: sorted) {
				$0.app.currentDate?.date.stripTime() ?? .distantPast
			}
			
			let sortedDates = grouped.keys.sorted(by: { sortAscending ? $0 > $1 : $0 < $1 })
			
			groupedAppsByDate = grouped.reduce(into: [:]) { result, pair in
				let key = formatter.string(from: pair.key)
				result[key] = pair.value
			}
			
			sortedSectionTitles = sortedDates.map { formatter.string(from: $0) }
			return sorted
		case .name:
			let sorted = filtered.sorted {
				let n1 = $0.app.name ?? ""
				let n2 = $1.app.name ?? ""
				let comparison = n1.localizedCaseInsensitiveCompare(n2) == .orderedAscending
				return sortAscending ? comparison : !comparison
			}
			groupedAppsByNameFirstLetter = Dictionary(grouping: sorted) {
				let first = $0.app.name?.trimmingCharacters(in: .whitespacesAndNewlines).first?.uppercased() ?? "#"
				return first.range(of: "[A-Z]", options: .regularExpression) != nil ? first : "#"
			}
			sortedSectionTitles = groupedAppsByNameFirstLetter.keys.sorted(by: {
				if $0 == "#" { return false }
				if $1 == "#" { return true }
				return sortAscending ? $0 < $1 : $0 > $1
			})
			return sorted
		}
	}
	
	func invalidateCache() {
		cachedSortedApps = calculateSortedApps()
		if let tableView = uiTableView {
			UIView.transition(with: tableView, duration: 0.3, options: [.transitionCrossDissolve], animations: {
				tableView.reloadData()
			})
		}
	}
	
	// MARK: TableView
	
	func numberOfSections(in tableView: UITableView) -> Int {
		switch sortOption {
		case .default: 1
		case .name, .date: sortedSectionTitles.count
		}
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch sortOption {
		case .default: _sortedApps.count
		case .name: groupedAppsByNameFirstLetter[sortedSectionTitles[section]]?.count ?? 0
		case .date: groupedAppsByDate[sortedSectionTitles[section]]?.count ?? 0
		}
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "AppCell", for: indexPath)
		let entry: (source: ASRepository, app: ASRepository.App)
		switch sortOption {
		case .default: entry = _sortedApps[indexPath.row]
		case .name: entry = groupedAppsByNameFirstLetter[sortedSectionTitles[indexPath.section]]?[indexPath.row] ?? _sortedApps[indexPath.row]
		case .date: entry = groupedAppsByDate[sortedSectionTitles[indexPath.section]]?[indexPath.row] ?? _sortedApps[indexPath.row]
		}
		cell.contentConfiguration = UIHostingConfiguration {
			SourceAppsCellView(source: entry.source, app: entry.app)
		}
		return cell
	}
	
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "SectionHeader")
		let title: String
		
		switch sortOption {
		case .default: title = .localized("%lld Apps", arguments: _sortedApps.count)
		case .name, .date: title = sortedSectionTitles[section]
		}
		
		headerView?.contentConfiguration = UIHostingConfiguration {
			HStack {
				Text(verbatim: title)
				Spacer()
			}
			.font(.headline)
			.padding(.vertical, 2)
		}
		
		return headerView
	}
	
	func sectionIndexTitles(for tableView: UITableView) -> [String]? {
		sortOption == .name ? sortedSectionTitles : nil
	}
	
	func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
		sortedSectionTitles.firstIndex(of: title) ?? 0
	}
	
	func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		let entry: (source: ASRepository, app: ASRepository.App)
		switch sortOption {
		case .default: entry = _sortedApps[indexPath.row]
		case .name: entry = groupedAppsByNameFirstLetter[sortedSectionTitles[indexPath.section]]?[indexPath.row] ?? _sortedApps[indexPath.row]
		case .date: entry = groupedAppsByDate[sortedSectionTitles[indexPath.section]]?[indexPath.row] ?? _sortedApps[indexPath.row]
		}
		
		return UIContextMenuConfiguration(
			identifier: nil,
			previewProvider: nil
		) { _ in
			let versionsMenu = UIMenu(
				title: .localized("Copy Download URLs"),
				image: UIImage(systemName: "list.bullet"),
				children: self._contextActions(for: entry.app, with: { version in
					UIPasteboard.general.string = version?.absoluteString
				}, image: UIImage(systemName: "doc.on.clipboard"))
			)
			
			let downloadsMenu = UIMenu(
				title: .localized("Previous Versions"),
				image: UIImage(systemName: "square.and.arrow.down.on.square"),
				children: self._contextActions(for: entry.app, with: { version in
					if let url = version {
						_ = DownloadManager.shared.startDownload(
							from: url,
							id: entry.app.currentUniqueId
						)
					}
				}, image: UIImage(systemName: "arrow.down"))
			)
			
			return UIMenu(children: [downloadsMenu, versionsMenu])
		}
	}
	
	// MARK: Actions
	
	private func _contextActions(
		for app: ASRepository.App,
		with action: @escaping (URL?) -> Void,
		image: UIImage?
	) -> [UIAction] {
		if let versions = app.versions, !versions.isEmpty {
			return versions.map { version in
				UIAction(
					title: version.version,
					image: image
				) { _ in
					action(version.downloadURL)
				}
			}
		} else {
			return [
				UIAction(
					title: app.currentVersion ?? "",
					image: image
				) { _ in
					action(app.currentDownloadUrl)
				}
			]
		}
	}
}}
