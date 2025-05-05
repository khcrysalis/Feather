//
//  SourceAppsTableView.swift
//  Feather
//
//  Created by samara on 3.05.2025.
//

import SwiftUI
import Esign

// MARK: - Representable

#warning("change this to a uicollectionview with grid and table stuff")

struct SourceAppsTableRepresentableView: UIViewRepresentable {
	var object: AltSource
	var source: ASRepository
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
		
		// header
		let header = UIHostingController(rootView: SourceNewsView(news: source.news))
		header.view.translatesAutoresizingMaskIntoConstraints = true
		header.view.backgroundColor = .clear
		let targetSize = header.view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
		header.view.frame = CGRect(origin: .zero, size: targetSize)
		tableView.tableHeaderView = header.view
		
		return tableView
	}
	
	func updateUIView(_ tableView: UITableView, context: Context) {
		context.coordinator.object = object
		context.coordinator.apps = source.apps
		context.coordinator.searchText = searchText
		context.coordinator.sortOption = sortOption
		context.coordinator.sortAscending = sortAscending
		tableView.reloadData()
	}
	
	func makeCoordinator() -> Coordinator {
		Coordinator(
			object: object,
			source: source,
			searchText: searchText,
			sortOption: sortOption,
			sortAscending: sortAscending
		)
	}
	
	// MARK: - Coordinator
	class Coordinator: NSObject, UITableViewDataSource, UITableViewDelegate {
		var object: AltSource
		var apps: [ASRepository.App]
		var searchText: String
		var sortOption: SourceAppsView.SortOption
		var sortAscending: Bool
		
		private var _sortedApps: [ASRepository.App] {
			let filtered = apps.filter {
				searchText.isEmpty || ($0.name?.localizedCaseInsensitiveContains(searchText) ?? false)
			}
			
			if sortOption == .default {
				if sortAscending {
					return filtered
				} else {
					return filtered.reversed()
				}
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
		
		init(
			object: AltSource,
			source: ASRepository,
			searchText: String,
			sortOption: SourceAppsView.SortOption,
			sortAscending: Bool
		) {
			self.object = object
			self.apps = source.apps
			self.searchText = searchText
			self.sortOption = sortOption
			self.sortAscending = sortAscending
		}
		
		func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { return 80 }
		func numberOfSections(in tableView: UITableView) -> Int { return 1 }
		
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
					Text("\(_sortedApps.count) Apps")
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
				let copyAction = UIAction(
					title: "Copy Download URL",
					image: UIImage(systemName: "doc.on.clipboard")
				) { _ in
					UIPasteboard.general.string = app.currentDownloadUrl?.absoluteString
				}
				
				let versionActions = app.versions?.map { version in
					UIAction(
						title: version.version,
						image: UIImage(systemName: "doc.on.clipboard")
					) { _ in
						UIPasteboard.general.string = version.downloadURL?.absoluteString
					}
				} ?? []
				
				let versionsMenu = UIMenu(
					title: "Other Links",
					image: UIImage(systemName: "list.bullet"),
					children: versionActions
				)
				
				return UIMenu(title: "", children: [copyAction, versionsMenu])
			}
		}
	}
	
	// MARK: -
}
