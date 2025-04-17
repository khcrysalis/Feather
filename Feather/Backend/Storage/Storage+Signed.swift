//
//  Storage+Signed.swift
//  Feather
//
//  Created by samara on 17.04.2025.
//

import CoreData

extension Storage {
	func addSigned(
		uuid: String,
		source: URL? = nil,
		completion: @escaping (Error?) -> Void
	) {
		var new = Signed(context: context)
		
		new.uuid = uuid
		new.source = source
		new.date = Date()
		extractBundleInfo(for: &new, using: FileManager.default.signed(uuid))
		
		do {
			try context.save()
			completion(nil)
		} catch {
			completion(error)
		}
	}
}
