//
//  IPAHandler.swift
//  Feather
//
//  Created by samara on 11.04.2025.
//

import Foundation
import Zip
import SwiftUI
import OSLog

final class AppFileHandler: NSObject, @unchecked Sendable {
	private let _fileManager = FileManager.default
	private let _uuid = UUID().uuidString
	private let _uniqueWorkDir: URL
	var uniqueWorkDirPayload: URL?

	private var _ipa: URL
	private let _install: Bool
	private let _download: Download?
	
	init(
		file ipa: URL,
		install: Bool = false,
		download: Download? = nil
	) {
		self._ipa = ipa
		self._install = install
		self._download = download
		self._uniqueWorkDir = _fileManager.temporaryDirectory
			.appendingPathComponent("FeatherImport_\(_uuid)", isDirectory: true)
		
		super.init()
		Logger.misc.debug("Import initiated for: \(self._ipa.lastPathComponent) with ID: \(self._uuid)")
	}
	
	func copy() async throws {
		try _fileManager.createDirectoryIfNeeded(at: _uniqueWorkDir)
		
		let destinationURL = _uniqueWorkDir.appendingPathComponent(_ipa.lastPathComponent)

		try _fileManager.removeFileIfNeeded(at: destinationURL)
		
		try _fileManager.copyItem(at: _ipa, to: destinationURL)
		_ipa = destinationURL
		Logger.misc.info("[\(self._uuid)] File copied to: \(self._ipa.path)")
	}
	
	func extract() async throws {
		if _ipa.pathExtension == "ipa" {
			Zip.addCustomFileExtension("ipa")
		}
		if _ipa.pathExtension == "tipa" {
			Zip.addCustomFileExtension("tipa")
		}
		
		let download = self._download
		
		try await withCheckedThrowingContinuation { continuation in
			DispatchQueue.global(qos: .utility).async {
				do {
					try Zip.unzipFile(
						self._ipa,
						destination: self._uniqueWorkDir,
						overwrite: true,
						password: nil,
						progress: { progress in
							if let download = download {
								DispatchQueue.main.async {
									download.unpackageProgress = progress
                                    if #available(iOS 26.0, *) {
                                        BackgroundTaskManager.shared.updateProgress(for: download.id, progress: download.overallProgress)
                                    }
								}
							}
						}
					)
					
					self.uniqueWorkDirPayload = self._uniqueWorkDir.appendingPathComponent("Payload")
					continuation.resume()
				} catch {
					continuation.resume(throwing: error)
				}
			}
		}
	}
	
	func move() async throws {
		guard let payloadURL = uniqueWorkDirPayload else {
			throw ImportedFileHandlerError.payloadNotFound
		}
		
		let destinationURL = try await _directory()
		
		guard _fileManager.fileExists(atPath: payloadURL.path) else {
			throw ImportedFileHandlerError.payloadNotFound
		}
		
		try _fileManager.moveItem(at: payloadURL, to: destinationURL)
		Logger.misc.info("[\(self._uuid)] Moved Payload to: \(destinationURL.path)")
		
		try? _fileManager.removeItem(at: _uniqueWorkDir)
	}
	
	func addToDatabase() async throws {
		let app = try await _directory()
		
		guard let appUrl = _fileManager.getPath(in: app, for: "app") else {
			return
		}
		
		let bundle = Bundle(url: appUrl)
		
		Storage.shared.addImported(
			uuid: _uuid,
			appName: bundle?.name,
			appIdentifier: bundle?.bundleIdentifier,
			appVersion: bundle?.version,
			appIcon: bundle?.iconFileName
		) { _ in
			Logger.misc.info("[\(self._uuid)] Added to database")
		}
	}
	
	private func _directory() async throws -> URL {
		// Documents/Feather/Unsigned/\(UUID)
		_fileManager.unsigned(_uuid)
	}
	
	func clean() async throws {
		try _fileManager.removeFileIfNeeded(at: _uniqueWorkDir)
	}
}

private enum ImportedFileHandlerError: Error {
	case payloadNotFound
}
