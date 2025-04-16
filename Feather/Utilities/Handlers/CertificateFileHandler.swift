//
//  CertificateFileHandler.swift
//  Feather
//
//  Created by samara on 15.04.2025.
//

import Foundation

final class CertificateFileHandler: NSObject {
	private let _fileManager = FileManager.default
	private let _uuid = UUID().uuidString
	
	private let _key: URL
	private let _provision: URL
	private let _keyPassword: String?
	
	init(key: URL, provision: URL, password: String? = nil) {
		self._key = key
		self._provision = provision
		self._keyPassword = password
		super.init()
	}
	
	func copy() async throws {
		let destinationURL = try await _directory()

		try _fileManager.createDirectory(at: destinationURL, withIntermediateDirectories: true)
		try _fileManager.copyItem(at: _key, to: destinationURL.appendingPathComponent(_key.lastPathComponent))
		try _fileManager.copyItem(at: _provision, to: destinationURL.appendingPathComponent(_provision.lastPathComponent))
	}
	
	func addToDatabase() async throws {
		Storage.shared.addCertificate(uuid: _uuid) { _ in
			print("[\(self._uuid)] Added to database")
		}
	}
	
	private func _directory() async throws -> URL {
		// Documents/Feather/Certificates/\(UUID)
		_fileManager.certificates(_uuid)
	}
}
