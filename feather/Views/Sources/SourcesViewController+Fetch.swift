//
//  SourcesViewController+Fetch.swift
//  feather
//
//  Created by samara on 5/28/24.
//

import Foundation
import UIKit
import CoreData

extension SourcesViewController {
	@objc func sourcesAddButtonTapped() {
		let alertController = UIAlertController(title: "Add Source", message: "Add Altstore Repo URL", preferredStyle: .alert)
		
		alertController.addTextField { textField in
			textField.placeholder = "URL"
		}
		
		let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
		alertController.addAction(cancelAction)
		
		let addSourceAction = UIAlertAction(title: "Add Source", style: .default) { _ in
			if let sourceURL = alertController.textFields?.first?.text {
				self.getData(urlString: sourceURL)
			}
		}
		alertController.addAction(addSourceAction)
		self.present(alertController, animated: true, completion: nil)
	}
	
	func getData(urlString: String) {
		guard let url = URL(string: urlString) else {
			print("Invalid URL")
			return
		}

		let repoManager = RepoManager()
		repoManager.downloadURL(from: url) { result in
			switch result {
			case .success(let data):
				let parseResult = repoManager.parse(data: data)
				switch parseResult {
				case .success(let source):
					print(source)
					self.saveSource(source, url: urlString)
				case .failure(let error):
					print("Error parsing data: \(error)")
				}
			case .failure(let error):
				print("Error downloading data: \(error)")
			}
		}
	}
	
	func saveSource(_ source: SourcesData, url: String) {
		let context = self.context

		// Check if a source with the same identifier already exists
		let fetchRequest: NSFetchRequest<Source> = Source.fetchRequest()
		fetchRequest.predicate = NSPredicate(format: "identifier == %@", source.identifier)

		do {
			let existingSources = try context.fetch(fetchRequest)
			if let existingSources = existingSources.first {
				print("Source with identifier '\(source.identifier)' already exists.")
				return
			}
		} catch {
			print("Error fetching existing sources: \(error)")
			return
		}

		let newSource = Source(context: context)
		newSource.name = source.name
		newSource.identifier = source.identifier
		newSource.sourceURL = URL(string: url)
		newSource.iconURL = source.iconURL

		for app in source.apps {
			let newApp = StoreApps(context: context)
			newApp.name = app.name
			newApp.developerName = app.developerName
			newApp.subtitle = app.subtitle
			newApp.bundleIdentifier = app.bundleIdentifier
			newApp.iconURL = app.iconURL
			newApp.downloadURL = app.downloadURL
			newApp.size = 0
			newApp.version = app.version
			newApp.versionDate = app.versionDate
			newApp.versionDescription = app.versionDescription
			newApp.localizedDescription = app.localizedDescription
			newApp.source = newSource
			newSource.addToApps(newApp)
		}

		do {
			try context.save()
			fetchSources()
		} catch {
			print("Error saving data: \(error)")
		}
	}

	
	func fetchSources() {
		let fetchRequest: NSFetchRequest<Source> = Source.fetchRequest()
		let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
		fetchRequest.sortDescriptors = [sortDescriptor]

		do {
			self.sources = try context.fetch(fetchRequest)
			print(sources ?? [])
			DispatchQueue.main.async {
				self.tableView.reloadData()
			}
		} catch {
			print("Error fetching sources: \(error)")
		}
	}

}
