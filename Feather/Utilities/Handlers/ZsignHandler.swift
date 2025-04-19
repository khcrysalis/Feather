//
//  ZsignHandler.swift
//  Feather
//
//  Created by samara on 17.04.2025.
//

import Foundation

final class ZsignHandler {
	private var _appUrl: URL
	private var _options: Options
	private var _certificate: CertificatePair?
	
	init(
		appUrl: URL,
		options: Options = OptionsManager.shared.options,
		cert: CertificatePair? = nil
	) {
		self._appUrl = appUrl
		self._options = options
		self._certificate = cert
	}
	
	func sign() async throws {
		guard let cert = _certificate else {
			return
			#warning("throw")
		}
		
		print(Storage.shared.getProvisionFile(for: cert)?.path ?? "")
		print(Storage.shared.getKeyFile(for: cert)?.path ?? "")
		print(cert.password ?? "")
		
		if Zsign.sign(
			appPath: _appUrl.relativePath,
			provisionPath: Storage.shared.getProvisionFile(for: cert)?.path ?? "",
			p12Path: Storage.shared.getKeyFile(for: cert)?.path ?? "",
			p12Password: cert.password ?? ""
		) {
			print("aaaa")
		} else {
			print("aaaa2")
		}
	}
	
	func adhocSign() async throws {
		
	}
}
