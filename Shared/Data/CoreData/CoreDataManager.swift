//
//  CDManager.swift
//  feather
//
//  Created by samara on 7/29/24.
//  Copyright (c) 2024 Samara M (khcrysalis)
//

import CoreData
import UIKit

final class CoreDataManager {
	static let shared = CoreDataManager()
	
	init() {}
	deinit {}
	
	lazy var persistentContainer: NSPersistentContainer = {
		let container = NSPersistentContainer(name: "Feather")
		container.loadPersistentStores(completionHandler: { (storeDescription, error) in
			if let error = error as NSError? {
				fatalError("Unresolved error \(error), \(error.userInfo)")
			}
		})
		
		return container
	}()
	
	var context: NSManagedObjectContext {
		persistentContainer.viewContext
	}
	
	func saveContext() {
		if context.hasChanges {
			do {
				try context.save()
			} catch {
				Debug.shared.log(message: "CoreDataManager.saveContext: \(error)", type: .critical)
			}
		}
	}
	
	/// Clear all objects from fetch request.
	func clear<T: NSManagedObject>(request: NSFetchRequest<T>, context: NSManagedObjectContext? = nil) {
		let context = context ?? self.context
		let deleteRequest = NSBatchDeleteRequest(fetchRequest: (request as? NSFetchRequest<NSFetchRequestResult>)!)
		do {
			_ = try context.execute(deleteRequest)
		} catch {
			Debug.shared.log(message: "CoreDataManager.clear: \(error.localizedDescription)", type: .error)
		}
	}
	
	func loadImage(from iconUrl: URL?) -> UIImage? {
		guard let iconUrl = iconUrl else { return nil }
		return UIImage(contentsOfFile: iconUrl.path)
	}
}

extension NSPersistentContainer {
	func performBackgroundTask<T>(_ block: @escaping (NSManagedObjectContext) -> T) async -> T {
		await withCheckedContinuation({ continuation in
			self.performBackgroundTask { context in
				let result = block(context)
				continuation.resume(returning: result)
			}
		})
	}
}
