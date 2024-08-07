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
				case .success((let data, _)):
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
	
	/// Save or update source data in Core Data
	private func saveSource(_ source: SourcesData, url: String, completion: @escaping (Error?) -> Void) {
		let context = self.context
		
		context.perform {
			do {
				
				if !self.sourceExists(withIdentifier: source.identifier, context: context) {
					let newSource = self.createNewSourceEntity(from: source, url: url, context: context)
				}
				
				try context.save()
				completion(nil)
			} catch {
				print("Error saving data: \(error)")
				completion(error)
			}
		}
	}
}
