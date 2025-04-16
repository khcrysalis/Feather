//
//  Storage+Imported.swift
//  Feather
//
//  Created by samara on 11.04.2025.
//

import CoreData

extension Storage {
	func addImported(
		uuid: String,
		url: URL?,
		source: URL? = nil,
		completion: @escaping (Error?) -> Void
	) {
		#warning("importing a url is not needed if we have a uuid")
		guard let url = url else {
			return
		}
		
		var new = Imported(context: context)
		
		new.uuid = uuid
		new.source = source
		new.date = Date()
		_extractBundleInfo(for: &new, using: url)
		
		do {
			try context.save()
			completion(nil)
		} catch {
			completion(error)
		}
	}
	
	func deleteImported(for app: Imported) {
		do {
			if let url = getUuidDirectory(for: app) {
				try FileManager.default.removeItem(at: url)
			}
			context.delete(app)
			saveContext()
		} catch {
			print(error)
		}
	}
	
	func getDirectory(for app: Imported) -> URL? {
		guard let url = getUuidDirectory(for: app) else {
			return nil
		}

		return FileManager.default.appBundle(in: url)
	}
	
	func getUuidDirectory(for app: Imported) -> URL? {
		guard let uuid = app.uuid else {
			return nil
		}
		
		return FileManager.default.unsigned(uuid)
	}
	
	private func _extractBundleInfo(
		for app: inout Imported,
		using url: URL
	) {
		guard let appUrl = FileManager.default.appBundle(in: url) else {
			return
		}
		
		let bundle = Bundle(url: appUrl)
		app.identifier = bundle?.bundleIdentifier
		app.name = bundle?.name
		app.icon = bundle?.iconFileName
		app.version = bundle?.version
	}
}
