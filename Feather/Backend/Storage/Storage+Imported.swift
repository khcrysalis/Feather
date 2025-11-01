//
//  Storage+Imported.swift
//  Feather
//
//  Created by samara on 11.04.2025.
//

import CoreData
import UIKit.UIImpactFeedbackGenerator

// MARK: - Class extension: Imported Apps
extension Storage {
	/// Check if an imported app with the same hash already exists
	func findDuplicateImported(hash: String) -> Imported? {
		let request = Imported.fetchRequest()
		request.predicate = NSPredicate(format: "fileHash == %@", hash)
		request.fetchLimit = 1
		
		return try? context.fetch(request).first
	}
	
	func addImported(
		uuid: String,
		source: URL? = nil,
		
		appName: String? = nil,
		appIdentifier: String? = nil,
		appVersion: String? = nil,
		appIcon: String? = nil,
		fileHash: String? = nil,
		fileName: String? = nil,
		
		completion: @escaping (Error?) -> Void
	) {
		let generator = UIImpactFeedbackGenerator(style: .light)
		
		let new = Imported(context: context)
		
		new.uuid = uuid
		new.source = source
		new.date = Date()
		// could possibly be nil, but thats fine.
		new.identifier = appIdentifier
		new.name = appName
		new.icon = appIcon
		new.version = appVersion
		new.fileHash = fileHash
		new.fileName = fileName
		
		saveContext()
		generator.impactOccurred()
		completion(nil)
	}
}
