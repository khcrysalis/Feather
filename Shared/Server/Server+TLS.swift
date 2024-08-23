//
//  Server+TLS.swift
//  feather
//
//  Created by samara on 22.08.2024.
//  Copyright © 2024 Lakr Aream. All Rights Reserved.
//  ORIGINALLY LICENSED UNDER GPL-3.0, MODIFIED FOR USE FOR FEATHER
//

import Foundation
import NIOSSL
import NIOTLS
import Vapor

extension Installer {
	static let sni = "app.localhost.direct"
	
	static let bundleKeyURL = Bundle.main.url(forResource: "localhost.direct", withExtension: "pem")
	static let bundleCrtURL = Bundle.main.url(forResource: "localhost.direct", withExtension: "crt")
	
	static let documentsKeyURL = getDocumentsDirectory().appendingPathComponent("localhost.direct.pem")
	static let documentsCrtURL = getDocumentsDirectory().appendingPathComponent("localhost.direct.crt")

	static func setupTLS() throws -> TLSConfiguration {
		let keyURL = FileManager.default.fileExists(atPath: documentsKeyURL.path) ? documentsKeyURL : bundleKeyURL
		let crtURL = FileManager.default.fileExists(atPath: documentsCrtURL.path) ? documentsCrtURL : bundleCrtURL
		
		guard let crtURL, let keyURL else {
			throw NSError(domain: "Installer", code: 0, userInfo: [
				NSLocalizedDescriptionKey: "Failed to load SSL certificates",
			])
		}
		
		return try TLSConfiguration.makeServerConfiguration(
			certificateChain: NIOSSLCertificate
				.fromPEMFile(crtURL.path)
				.map { NIOSSLCertificateSource.certificate($0) },
			privateKey: .file(keyURL.path)
		)
	}
}
