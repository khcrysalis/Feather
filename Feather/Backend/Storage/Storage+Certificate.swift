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
		let new = CertificatePair(context: context)
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
	
	#warning("this can be simplified into one function")
	func getKeyFile(for cert: CertificatePair) -> URL? {
		guard let url = getUuidDirectory(for: cert) else {
			return nil
		}
		
		return FileManager.default.getPath(in: url, for: "p12")
	}
	
	#warning("this can be simplified into one function")
	func getProvisionFile(for cert: CertificatePair) -> URL? {
		guard let url = getUuidDirectory(for: cert) else {
			return nil
		}
		
		return FileManager.default.getPath(in: url, for: "mobileprovision")
	}
	
	func getProvisionFileDecoded(for cert: CertificatePair) -> Certificate? {
		guard let url = getProvisionFile(for: cert) else {
			return nil
		}
		
		let read = CertificateReader(url)
		return read.decoded
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
