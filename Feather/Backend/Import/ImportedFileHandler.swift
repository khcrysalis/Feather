//
//  IPAHandler.swift
//  Feather
//
//  Created by samara on 11.04.2025.
//

import Foundation
import Zip

final class ImportedFileHandler: NSObject {
	private let _fileManager = FileManager.default
	private let _uuid = UUID().uuidString
	private var _ipaDestination: URL? = nil
	private let _uniqueWorkDir: URL
	
	private var _ipa: URL
	private let _install: Bool
	
	init(
		file ipa: URL,
		install: Bool = false
	) {
		self._ipa = ipa
		self._install = install
		self._uniqueWorkDir = _fileManager.temporaryDirectory
			.appendingPathComponent("FeatherImport_\(_uuid)", isDirectory: true)
		
		super.init()
		print("Import initiated for: \(_ipa.lastPathComponent) with ID: \(_uuid)")
	}
	
	func copy() async throws {
		if !_fileManager.fileExists(atPath: _uniqueWorkDir.path) {
			try _fileManager.createDirectory(at: _uniqueWorkDir, withIntermediateDirectories: true)
		}
		
		let destinationURL = _uniqueWorkDir.appendingPathComponent(_ipa.lastPathComponent)
		
		if _fileManager.fileExists(atPath: destinationURL.path) {
			try _fileManager.removeItem(at: destinationURL)
		}
		
		try _fileManager.copyItem(at: _ipa, to: destinationURL)
		_ipa = destinationURL
		print("File copied to: \(_ipa.path)")
	}
	
	func extract() async throws {
		Zip.addCustomFileExtension("ipa")
		Zip.addCustomFileExtension("tipa")
		
		try Zip.unzipFile(_ipa, destination: _uniqueWorkDir, overwrite: true, password: nil, progress: { progress in
			print("[\(self._uuid)] Unzip progress: \(progress)")
		})
		
		let payloadURL = _uniqueWorkDir.appendingPathComponent("Payload")
		let destinationURL = try await _directory()
		
		guard _fileManager.fileExists(atPath: payloadURL.path) else {
			throw ImportedFileHandlerError.payloadNotFound
		}
		
		try _fileManager.moveItem(at: payloadURL, to: destinationURL)
		self._ipaDestination = destinationURL
		print("[\(_uuid)] Moved Payload to: \(destinationURL.path)")
		
		try? _fileManager.removeItem(at: _uniqueWorkDir)
	}
	
	func addToDatabase() async throws {
		Storage.shared.addImported(uuid: _uuid, url: _ipaDestination ?? nil) { _ in
			print("[\(self._uuid)] Added to database")
		}
	}
	
	private func _directory() async throws -> URL {
		// Documents/Feather/Unsigned/\(UUID)
		_fileManager.unsigned(_uuid)
	}
}

private enum ImportedFileHandlerError: Error {
	case payloadNotFound
}
