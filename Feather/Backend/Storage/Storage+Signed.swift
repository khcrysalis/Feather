//
//  Storage+Signed.swift
//  Feather
//
//  Created by samara on 17.04.2025.
//

import CoreData
import UIKit.UIImpactFeedbackGenerator

// MARK: - Class extension: Signed Apps
extension Storage {
	func addSigned(
		uuid: String,
		source: URL? = nil,
		certificate: CertificatePair? = nil,
		completion: @escaping (Error?) -> Void
	) {
		let generator = UIImpactFeedbackGenerator(style: .light)
		
		var new = Signed(context: context)
		
		new.uuid = uuid
		new.source = source
		new.date = Date()
		// if nil, we assume adhoc or certificate was deleted afterwards
		new.certificate = certificate
		
		extractBundleInfo(for: &new, using: FileManager.default.signed(uuid))
		
		do {
			try context.save()
			generator.impactOccurred()
			completion(nil)
		} catch {
			completion(error)
		}
	}
}
