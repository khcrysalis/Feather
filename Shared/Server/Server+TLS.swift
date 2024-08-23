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
	static let key = Bundle.main.url(
		forResource: "localhost.direct",
		withExtension: "pem"
	)
	static let crt = Bundle.main.url(
		forResource: "localhost.direct",
		withExtension: "crt"
	)

	static func setupTLS() throws -> TLSConfiguration {
		guard let crt, let key else {
			throw NSError(domain: "Installer", code: 0, userInfo: [
				NSLocalizedDescriptionKey: "Failed to load ssl certificates",
			])
		}
		return try TLSConfiguration.makeServerConfiguration(
			certificateChain: NIOSSLCertificate
				.fromPEMFile(crt.path)
				.map { NIOSSLCertificateSource.certificate($0) },
			privateKey: .file(key.path)
		)
	}
}
