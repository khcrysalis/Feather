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
			throw SigningFileHandlerError.missingCertifcate
		}
		
		if !Zsign.sign(
			appPath: _appUrl.relativePath,
			provisionPath: Storage.shared.getProvisionFile(for: cert)?.path ?? "",
			p12Path: Storage.shared.getKeyFile(for: cert)?.path ?? "",
			p12Password: cert.password ?? "",
			customIdentifier: _options.appIdentifier ?? "",
			customName: _options.appName ?? "",
			customVersion: _options.appVersion ?? "",
			removeProvision: !_options.removeProvisioning
		) {
			throw SigningFileHandlerError.signFailed
		}
	}
	
	func adhocSign() async throws {
		if !Zsign.sign(
			appPath: _appUrl.relativePath,
			customIdentifier: _options.appIdentifier ?? "",
			customName: _options.appName ?? "",
			customVersion: _options.appVersion ?? "",
			adhoc: true,
			removeProvision: !_options.removeProvisioning
		) {
			throw SigningFileHandlerError.signFailed
		}
	}
}
