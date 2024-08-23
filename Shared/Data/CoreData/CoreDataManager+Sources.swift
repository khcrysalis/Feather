//
//  CoreDataManager+DownloadedApps.swift
//  feather
//
//  Created by samara on 8/2/24.
//  Copyright (c) 2024 Samara M (khcrysalis)
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
				Debug.shared.log(message: "Invalid URL")
				completion(nil)
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
						Debug.shared.log(message: "Error parsing data: \(error)")
						completion(error)
					}
				case .failure(let error):
					Debug.shared.log(message: "Error downloading data: \(error)")
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
				Debug.shared.log(message: "Error checking for existing source: \(error)")
				return false
			}
	}
	
	/// Create a new source entity from source data
	private func createNewSourceEntity(from
		sourceData: SourcesData,
		url: String,
		iconURL: URL?,
		context: NSManagedObjectContext) -> Source 
	{
		let newSource = Source(context: context)
		newSource.name = sourceData.name
		newSource.identifier = sourceData.identifier
		newSource.sourceURL = URL(string: url)
		
		if (sourceData.iconURL != nil) {
			newSource.iconURL = sourceData.iconURL
		} else if (iconURL != nil) {
			newSource.iconURL = iconURL
		}
		
		return newSource
	}
	
	/// Create a new source entity manually
	private func createNewSourceEntity(
		name: String,
		id: String,
		url: String,
		iconURL: URL?,
		context: NSManagedObjectContext) -> Source
	{
		let newSource = Source(context: context)
		newSource.name = name
		newSource.identifier = id
		newSource.sourceURL = URL(string: url)
		
		newSource.iconURL = iconURL
		
		return newSource
	}
	
	/// Save SourcesData in Core Data
	private func saveSource(_ source: SourcesData, url: String, completion: @escaping (Error?) -> Void) {
		let context = self.context
		
		context.perform {
			do {
				
				if !self.sourceExists(withIdentifier: source.identifier, context: context) {
					_ = self.createNewSourceEntity(from: source, url: url, iconURL: source.apps[0].iconURL, context: context)
				}
				
				try context.save()
				completion(nil)
			} catch {
				Debug.shared.log(message: "Error saving data: \(error)")
				completion(error)
			}
		}
	}
	
	/// Save data in Core Data
	public func saveSource(name: String, id: String, iconURL: URL? = nil, url: String, completion: @escaping (Error?) -> Void) {
		let context = self.context
		
		context.perform {
			do {
				
				if !self.sourceExists(withIdentifier: id, context: context) {
					_ = self.createNewSourceEntity(name: name, id: id, url: url, iconURL: iconURL, context: context)
				}
				
				try context.save()
				completion(nil)
			} catch {
				Debug.shared.log(message: "Error saving data: \(error)")
				completion(error)
			}
		}
	}
}
