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
	
	private var _ipa: URL
	private let _install: Bool
	
	init(
		file ipa: URL,
		install: Bool = false
	) {
		self._ipa = ipa
		self._install = install
		super.init()
		print(_ipa)
	}
	
	func copy() async throws {
		let tmpURL = _fileManager.temporaryDirectory
		let destinationURL = tmpURL.appendingPathComponent(_ipa.lastPathComponent)
		
		if _fileManager.fileExists(atPath: destinationURL.path) {
			try _fileManager.removeItem(at: destinationURL)
		}
		
		try _fileManager.copyItem(at: _ipa, to: destinationURL)
		_ipa = destinationURL
		print(_ipa)
	}
	
	func extract() async throws {
		let tmpURL = _fileManager.temporaryDirectory
		
		Zip.addCustomFileExtension("ipa")
		Zip.addCustomFileExtension("tipa")
		
		try Zip.unzipFile(_ipa, destination: tmpURL, overwrite: true, password: nil, progress: { progress in
			print("Unzip progress: \(progress)")
		})
		
		let payloadURL = tmpURL.appendingPathComponent("Payload")
		let destinationURL = try await _directory()
		
		guard _fileManager.fileExists(atPath: payloadURL.path) else {
			throw ImportedFileHandlerError.payloadNotFound
		}
		
		try _fileManager.moveItem(at: payloadURL, to: destinationURL)
		self._ipaDestination = destinationURL
		print("Moved Payload to: \(destinationURL.path)")
	}
	
	func addToDatabase() async throws {
		Storage.shared.addImported(uuid: _uuid, url: _ipaDestination ?? nil) { _ in
			print("done?")
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
