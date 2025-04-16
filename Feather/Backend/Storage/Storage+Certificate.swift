//
//  Storage+Certificate.swift
//  Feather
//
//  Created by samara on 16.04.2025.
//

import CoreData

extension Storage {
	func addCertificate(
		uuid: String,
		password: String? = nil,
		completion: @escaping (Error?) -> Void
	) {
		var new = CertificatePair(context: context)
		new.uuid = uuid
		new.date = Date()
		new.password = password
		
		do {
			try context.save()
			completion(nil)
		} catch {
			completion(error)
		}
	}
	
	func deleteCertificate(for cert: CertificatePair) {
		do {
			if let url = getUuidDirectory(for: cert) {
				try FileManager.default.removeItem(at: url)
			}
			context.delete(cert)
			saveContext()
		} catch {
			print(error)
		}
	}
	
	func getUuidDirectory(for cert: CertificatePair) -> URL? {
		guard let uuid = cert.uuid else {
			return nil
		}
		
		return FileManager.default.certificates(uuid)
	}
	
	private func _extractCertificateInfo(
		for app: inout CertificatePair
	) {}
}
