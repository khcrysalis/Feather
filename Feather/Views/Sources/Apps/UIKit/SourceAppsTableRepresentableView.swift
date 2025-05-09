//
//  SourceAppsTableView.swift
//  Feather
//
//  Created by samara on 3.05.2025.
//

import SwiftUI
import AltSourceKit

// MARK: - Representable

#warning("change this to a uicollectionview with grid and table stuff")

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
	
	// MARK: - Coordinator
	class Coordinator: NSObject, UITableViewDataSource, UITableViewDelegate {
		var sources: [ASRepository]
		var searchText: String
		var sortOption: SourceAppsView.SortOption
		var sortAscending: Bool
		
		private var cachedSortedApps: [ASRepository.App] = []
		weak var uiTableView: UITableView?
		
		private var _apps: [ASRepository.App] {
			sources.flatMap { $0.apps }
		}
		
		private var _sortedApps: [ASRepository.App] {
			if !cachedSortedApps.isEmpty {
				return cachedSortedApps
			}
			
			cachedSortedApps = calculateSortedApps()
			return cachedSortedApps
		}
		
		init(
			sources: [ASRepository],
			searchText: String,
			sortOption: SourceAppsView.SortOption,
			sortAscending: Bool
		) {
			self.sources = sources
			self.searchText = searchText
			self.sortOption = sortOption
			self.sortAscending = sortAscending
			super.init()
		}
		
		private func calculateSortedApps() -> [ASRepository.App] {
			let allApps = _apps
			
			// Filter
			let filtered = allApps.filter {
				searchText.isEmpty || ($0.name?.localizedCaseInsensitiveContains(searchText) ?? false)
			}
			
			// Sort
			if sortOption == .default {
				return sortAscending ? filtered : filtered.reversed()
			}
			
			return filtered.sorted { app1, app2 in
				let comparison: Bool
				switch sortOption {
				case .name:
					let name1 = app1.name ?? ""
					let name2 = app2.name ?? ""
					comparison = name1.localizedCaseInsensitiveCompare(name2) == .orderedAscending
				case .date:
					let date1 = app1.currentDate?.date ?? Date.distantPast
					let date2 = app2.currentDate?.date ?? Date.distantPast
					comparison = date1 < date2
				case .default:
					comparison = true
				}
				
				return sortAscending ? comparison : !comparison
			}
		}
		
		// Invalidate cache when data changes
		func invalidateCache() {
			cachedSortedApps = calculateSortedApps()
			if let tableView = uiTableView {
				UIView.transition(with: tableView,  duration: 0.3, options: [.transitionCrossDissolve], animations: {
					tableView.reloadData()
				}, completion: nil)
			}
		}
		
		// MARK: - Delegate
		func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
			return UITableView.automaticDimension
		}
		
		func numberOfSections(in tableView: UITableView) -> Int {
			return 1
		}
		
		func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
			return _sortedApps.count
		}
		
		func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
			let cell = tableView.dequeueReusableCell(withIdentifier: "AppCell", for: indexPath)
			let app = _sortedApps[indexPath.row]
			
			cell.contentConfiguration = UIHostingConfiguration {
				SourceAppsCellView(app: app)
			}
			
			return cell
		}
		
		func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
			let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "SectionHeader")
			
			headerView?.contentConfiguration = UIHostingConfiguration {
				HStack {
					Text(verbatim: .localized("%lld Apps", arguments: _sortedApps.count))
					Spacer()
				}
				.font(.headline)
				.padding(.vertical, 2)
			}
			
			return headerView
		}
		
		func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
			let app = _sortedApps[indexPath.row]
			
			return UIContextMenuConfiguration(
				identifier: nil,
				previewProvider: nil
			) { _ in
				let versionsMenu = UIMenu(
					title: .localized("Copy Download URLs"),
					image: UIImage(systemName: "list.bullet"),
					children: self._contextActions(for: app, with: { version in
						UIPasteboard.general.string = version?.absoluteString
					}, image: UIImage(systemName: "doc.on.clipboard"))
				)
				
				let downloadsMenu = UIMenu(
					title: .localized("Previous Versions"),
					image: UIImage(systemName: "square.and.arrow.down.on.square"),
					children: self._contextActions(for: app, with: { version in
						if let url = version {
							_ = DownloadManager.shared.startDownload(
								from: url,
								id: app.currentUniqueId
							)
						}
					}, image: UIImage(systemName: "arrow.down"))
				)
				
				return UIMenu(children: [downloadsMenu, versionsMenu])
			}
		}
		
		// MARK: - Actions
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
	}
	
	// MARK: -
}
