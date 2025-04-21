//
//  Storage+Sources.swift
//  Feather
//
//  Created by samara on 12.04.2025.
//

import CoreData

// MARK: - Class extension: Sources
extension Storage {
	func addSource(
		_ url: URL,
		name: String? = "Unknown",
		identifier: String,
		iconURL: URL? = nil,
		completion: @escaping (Error?) -> Void
	) {
		if _sourceExists(identifier) {
			completion(.none)
		}

		let new = AltSource(context: context)

		new.name = name
		new.date = Date()
		new.identifier = identifier
		new.sourceURL = url
		new.iconURL = iconURL

		do {
			try context.save()
			completion(nil)
		} catch {
			completion(error)
		}
	}

	func addSource(
		_ url: URL,
		repository: Repository,
		deferSave: Bool = false,
		completion: @escaping (Error?) -> Void
	) {
		if _sourceExists(repository.id) {
			completion(.none)
		}

		let new = AltSource(context: context)

		new.name = repository.name
		new.date = Date()
		new.identifier = repository.id
		new.sourceURL = url
		new.iconURL = repository.iconURL

		do {
			if !deferSave {
				try context.save()
			}
			completion(nil)
		} catch {
			completion(error)
		}
	}

	func addSources(
		repos: [URL: Repository],
		completion: @escaping (Error?) -> Void
	) {
		for (url, repo) in repos {
			addSource(url, repository: repo, deferSave: true) { error in
				if let error = error {
					completion(error)
				}
			}
		}

		do {
			try context.save()
			completion(nil)
		} catch {
			completion(error)
		}
	}

	func deleteSource(for source: AltSource) {
		context.delete(source)
		saveContext()
	}

	private func _sourceExists(_ identifier: String) -> Bool {
		let fetchRequest: NSFetchRequest<AltSource> = AltSource.fetchRequest()
		fetchRequest.predicate = NSPredicate(format: "identifier == %@", identifier)

		do {
			let count = try context.count(for: fetchRequest)
			return count > 0
		} catch {
			print("Error checking if repository exists: \(error)")
			return false
		}
	}
}
