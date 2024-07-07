//
//  SourceDownload.swift
//  feather
//
//  Created by samara on 7/7/24.
//

import Foundation
import CoreData

extension SourcesViewController {
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
			if existingSources.first != nil {
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
			newApp.uuid = UUID().uuidString
			
			if let versions = app.versions {
				for version in versions {
					let cool = StoreVersions(context: context)
					cool.downloadURL = version.downloadURL
					cool.localizedDescription = version.localizedDescription
					cool.version = version.version
					cool.size = 0
					cool.date = nil
					newApp.addToVersions(cool)
				}
			}

			
			newSource.addToApps(newApp)
		}

		do {
			try context.save()
			fetchSources()
		} catch {
			print("Error saving data: \(error)")
		}
	}
}
