//
//  CoreDataManager+Certificates.swift
//  feather
//
//  Created by samara on 8/3/24.
//  Copyright (c) 2024 Samara M (khcrysalis)
//

import Foundation
import CoreData

extension CoreDataManager {
	/// clear certificates data
	func clearCertificate(
		context: NSManagedObjectContext? = nil) {
			let context = context ?? self.context
			clear(request: Certificate.fetchRequest(), context: context)
	}
	
	func getDatedCertificate(
		context: NSManagedObjectContext? = nil) -> [Certificate] {
			let request: NSFetchRequest<Certificate> = Certificate.fetchRequest()
			request.sortDescriptors = [NSSortDescriptor(key: "dateAdded", ascending: true)]
			return (try? (context ?? self.context).fetch(request)) ?? []
	}
	
	func getCurrentCertificate(
		context: NSManagedObjectContext? = nil) -> Certificate? {
			let context = context ?? self.context
			let row = Preferences.selectedCert
			let certificates = getDatedCertificate(context: context)
			if certificates.indices.contains(row) {
				return certificates[row]
			} else {
				return nil
			}
	}

	
	func addToCertificates(cert: Cert, files: [CertImportingViewController.FileType: Any], context: NSManagedObjectContext? = nil) {
		let context = context ?? self.context
		
		guard let provisionPath = files[.provision] as? URL else {
			Debug.shared.log(message: "Provisioning file URL is missing")
			return
		}
		
		let p12Path = files[.p12] as? URL
		let uuid = UUID().uuidString
		
		let newCertificate = createCertificateEntity(uuid: uuid, provisionPath: provisionPath, p12Path: p12Path, password: files[.password] as? String, context: context)
		let certData = createCertificateDataEntity(cert: cert, context: context)
		newCertificate.certData = certData
		
		do {
			try saveCertificateFiles(uuid: uuid, provisionPath: provisionPath, p12Path: p12Path)
			try context.save()
			NotificationCenter.default.post(name: Notification.Name("cfetch"), object: nil)
		} catch {
			Debug.shared.log(message: "Error: \(error)", type: .error)
		}
	}

	private func createCertificateEntity(uuid: String, provisionPath: URL, p12Path: URL?, password: String?, context: NSManagedObjectContext) -> Certificate {
		let newCertificate = Certificate(context: context)
		newCertificate.uuid = uuid
		newCertificate.provisionPath = provisionPath.lastPathComponent
		newCertificate.p12Path = p12Path?.lastPathComponent
		newCertificate.dateAdded = Date()
		newCertificate.password = password
		return newCertificate
	}

	private func createCertificateDataEntity(cert: Cert, context: NSManagedObjectContext) -> CertificateData {
		let certData = CertificateData(context: context)
		certData.appIDName = cert.AppIDName
		certData.creationDate = cert.CreationDate
		certData.expirationDate = cert.ExpirationDate
		certData.isXcodeManaged = cert.IsXcodeManaged
		certData.name = cert.Name
		certData.pPQCheck = cert.PPQCheck ?? false
		certData.teamName = cert.TeamName
		certData.uuid = cert.UUID
		certData.version = Int32(cert.Version)
		return certData
	}

	private func saveCertificateFiles(uuid: String, provisionPath: URL, p12Path: URL?) throws {
		let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
		let destinationDirectory = documentsDirectory
			.appendingPathComponent("Certificates")
			.appendingPathComponent(uuid)
		
		try FileManager.default.createDirectory(at: destinationDirectory, withIntermediateDirectories: true, attributes: nil)
		try CertData.copyFile(from: provisionPath, to: destinationDirectory)
		try CertData.copyFile(from: p12Path, to: destinationDirectory)
	}
	
    func getCertifcatePath(source: Certificate?) throws -> URL {
        guard let source, let uuid = source.uuid else { throw FileProcessingError.missingFile("Certificate or UUID") }
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let destinationDirectory = documentsDirectory
            .appendingPathComponent("Certificates")
            .appendingPathComponent(uuid)
        
        return destinationDirectory
    }
	
	func deleteAllCertificateContent(for app: Certificate) {
		do {
			CoreDataManager.shared.context.delete(app)
			try FileManager.default.removeItem(at: getCertifcatePath(source: app))
			try context.save()
		} catch {
			Debug.shared.log(message: "CoreDataManager.deleteAllSignedAppContent: \(error)", type: .error)
		}
	}
}
