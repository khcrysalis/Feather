//
//  Storage+Imported.swift
//  Feather
//
//  Created by samara on 11.04.2025.
//

import CoreData

// MARK: - Class extension: Imported Apps
extension Storage {
	func addImported(
		uuid: String,
		source: URL? = nil,
		completion: @escaping (Error?) -> Void
	) {
		var new = Imported(context: context)
		
		new.uuid = uuid
		new.source = source
		new.date = Date()
		extractBundleInfo(for: &new, using: FileManager.default.unsigned(uuid))
		
		do {
			try context.save()
			completion(nil)
		} catch {
			completion(error)
		}
	}
}
