//
//  Persistence.swift
//  Feather
//
//  Created by samara on 10.04.2025.
//

import CoreData

// MARK: - Class
final class Storage: ObservableObject {
	static let shared = Storage()
	let container: NSPersistentContainer
	
	private let _name: String = "Feather"
	
	init(inMemory: Bool = false) {
		container = NSPersistentContainer(name: _name)
		
		if inMemory {
			container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
		} else {
			if
				let appGroupURL = FileManager.default
					.containerURL(forSecurityApplicationGroupIdentifier: "group.thewonderofyou.Feather")
			{
				let storeURL = appGroupURL.appendingPathComponent("\(_name).sqlite")
				let description = NSPersistentStoreDescription(url: storeURL)
				container.persistentStoreDescriptions = [description]
			}
		}
		
		container.loadPersistentStores { (storeDescription, error) in
			if let error = error as NSError? {
				fatalError("Unresolved error \(error), \(error.userInfo)")
			}
		}
		
		container.viewContext.automaticallyMergesChangesFromParent = true
	}
	
	var context: NSManagedObjectContext {
		container.viewContext
	}
	
	func saveContext() {
		if context.hasChanges {
			do {
				try context.save()
			} catch {
				print("saveContext: \(error)")
			}
		}
	}
	
	func clearContext<T: NSManagedObject>(request: NSFetchRequest<T>) {
		let deleteRequest = NSBatchDeleteRequest(fetchRequest: (request as? NSFetchRequest<NSFetchRequestResult>)!)
		do {
			_ = try context.execute(deleteRequest)
		} catch {
			print("clear: \(error.localizedDescription)")
		}
	}
}
