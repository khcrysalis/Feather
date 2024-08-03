//
//  CoreDataManager+DownloadedApps.swift
//  feather
//
//  Created by samara on 8/2/24.
//

import CoreData

extension CoreDataManager {
	
	/// Clear all sources from Core Data
	func clearSources(
		context: NSManagedObjectContext? = nil) {
			let context = context ?? self.context
			clear(request: Source.fetchRequest(), context: context)
	}
	
	/// Fetch all sources sorted alphabetically by name
	func getAZSources(
		context: NSManagedObjectContext? = nil) -> [Source] {
			let request: NSFetchRequest<Source> = Source.fetchRequest()
			request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
			return (try? (context ?? self.context).fetch(request)) ?? []
	}
	
	/// Fetch a source by its identifier
	func getSource(
		identifier: String,
		context: NSManagedObjectContext? = nil) -> Source? {
			let context = context ?? self.context
			let request: NSFetchRequest<Source> = Source.fetchRequest()
			request.predicate = NSPredicate(format: "identifier == %@", identifier)
			request.fetchLimit = 1
			return (try? context.fetch(request))?.first
	}
	
	/// Fetch and save source data from a given URL
	func getSourceData(
		urlString: String,
		completion: @escaping (Error?) -> Void) {
			guard let url = URL(string: urlString) else {
				let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
				print(error.localizedDescription)
				completion(error)
				return
		}
			let repoManager = SourceGET()
			repoManager.downloadURL(from: url) { result in
				switch result {
				case .success(let data):
					switch repoManager.parse(data: data) {
					case .success(let source):
						self.saveSource(source, url: urlString, completion: completion)
					case .failure(let error):
						print("Error parsing data: \(error)")
						completion(error)
					}
				case .failure(let error):
					print("Error downloading data: \(error)")
					completion(error)
				}
		}
	}
	
	/// Check if a source exists with a specific identifier
	private func sourceExists(
		withIdentifier identifier: String,
		context: NSManagedObjectContext) -> Bool {
			let request: NSFetchRequest<Source> = Source.fetchRequest()
			request.predicate = NSPredicate(format: "identifier == %@", identifier)
			do {
				return try context.count(for: request) > 0
			} catch {
				print("Error checking for existing source: \(error)")
				return false
			}
	}
	
	/// Create a new source entity from source data
	private func createNewSourceEntity(
		from sourceData: SourcesData,
		url: String,
		context: NSManagedObjectContext) -> Source {
			let newSource = Source(context: context)
			newSource.name = sourceData.name
			newSource.identifier = sourceData.identifier
			newSource.sourceURL = URL(string: url)
			newSource.iconURL = sourceData.iconURL
			return newSource
	}
	
	/// Create a new app entity from app data
	private func createNewAppEntity(
		from appData: StoreAppsData,
		context: NSManagedObjectContext) -> StoreApps {
			let newApp = StoreApps(context: context)
			newApp.name = appData.name
			newApp.developerName = appData.developerName
			newApp.subtitle = appData.subtitle
			newApp.bundleIdentifier = appData.bundleIdentifier
			newApp.iconURL = appData.iconURL
			newApp.downloadURL = appData.downloadURL
			newApp.size = 0
			newApp.version = appData.version
			newApp.versionDate = appData.versionDate
			newApp.versionDescription = appData.versionDescription
			newApp.localizedDescription = appData.localizedDescription
			newApp.uuid = UUID().uuidString
			if let versions = appData.versions {
				for version in versions {
					let newVersion = StoreVersions(context: context)
					newVersion.downloadURL = version.downloadURL
					newVersion.localizedDescription = version.localizedDescription
					newVersion.version = version.version
					newVersion.size = 0
					newVersion.date = nil
					newApp.addToVersions(newVersion)
				}
			}
			return newApp
	}
	
	/// Save or update source data in Core Data
	private func saveSource(
		_ source: SourcesData,
		url: String,
		completion: @escaping (Error?) -> Void) {
			let context = self.context
		
			if let existingSource = getSource(identifier: source.identifier, context: context) {
				existingSource.name = source.name
				existingSource.sourceURL = URL(string: url)
				existingSource.iconURL = source.iconURL
				
				if let existingAppsSet = existingSource.apps as? Set<StoreApps> {
					let existingAppsArray = Array(existingAppsSet)
					existingAppsArray.forEach { context.delete($0) }
				}
				
				source.apps.forEach {
					let newApp = createNewAppEntity(from: $0, context: context)
					existingSource.addToApps(newApp)
				}
			} else {
				let newSource = createNewSourceEntity(from: source, url: url, context: context)
				source.apps.forEach {
					let newApp = createNewAppEntity(from: $0, context: context)
					newSource.addToApps(newApp)
				}
			}
		
			do {
				try context.save()
				completion(nil)
			} catch {
				print("Error saving data: \(error)")
				completion(error)
			}
	}
	
	/// Refresh sources by updating each one
	func refreshSources(
		completion: @escaping (Error?) -> Void) {
			let sources = getAZSources()
			let dispatchGroup = DispatchGroup()
			var encounteredError: Error?
			
			for source in sources {
				guard let url = source.sourceURL else {
					print("Invalid URL for source with identifier: \(source.identifier ?? "")")
					continue
				}
				
				dispatchGroup.enter()
				refreshSource(url: url.absoluteString) { error in
					if let error = error {
						print("Error refreshing source \(source.identifier ?? ""): \(error)")
						encounteredError = error
					}
					dispatchGroup.leave()
				}
			}

			dispatchGroup.notify(queue: .main) {
				completion(encounteredError)
			}
	}
	
	/// Refresh a specific source
	private func refreshSource(
		url: String,
		completion: @escaping (Error?) -> Void) {
			getSourceData(urlString: url, completion: completion)
	}
}

extension CoreDataManager {
	func getAZStoreAppVersions(for app: StoreApps) -> [StoreVersions] {
		guard let versionsSet = app.versions as? Set<StoreVersions> else { return [] }
		let sortedVersionsArray = Array(versionsSet).sorted { (lhs, rhs) -> Bool in
			let lhsVersion = lhs.version ?? ""
			let rhsVersion = rhs.version ?? ""
			return lhsVersion > rhsVersion
		}
		
		return sortedVersionsArray
	}
	
	func getAZStoreApps(from appsSet: Set<StoreApps>) -> [StoreApps] {
		let appsArray = Array(appsSet)
		
		let sortedAppsArray = appsArray.sorted { (lhs: StoreApps, rhs: StoreApps) -> Bool in
			let lhsName = lhs.name ?? ""
			let rhsName = rhs.name ?? ""
			return lhsName < rhsName
		}
		
		return sortedAppsArray
	}

}
