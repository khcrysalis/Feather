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
	private let _fileHash: String?
	private let _fileName: String?
	
	init(
		file ipa: URL,
		install: Bool = false,
		download: Download? = nil,
		fileHash: String? = nil,
		fileName: String? = nil
	) {
		self._ipa = ipa
		self._install = install
		self._download = download
		self._fileHash = fileHash
		self._fileName = fileName
		self._uniqueWorkDir = _fileManager.temporaryDirectory
			.appendingPathComponent("FeatherImport_\(_uuid)", isDirectory: true)
		
		super.init()
		Logger.misc.debug("Import initiated for: \(self._ipa.lastPathComponent) with ID: \(self._uuid)")
	}
	
	func copy() async throws {
		Logger.misc.info("[\(self._uuid)] 📂 Starting copy process...")
		Logger.misc.info("[\(self._uuid)] 📍 Source: \(self._ipa.path)")
		Logger.misc.info("[\(self._uuid)] 📍 Source exists: \(self._fileManager.fileExists(atPath: self._ipa.path))")
		
		do {
			try self._fileManager.createDirectoryIfNeeded(at: self._uniqueWorkDir)
			Logger.misc.info("[\(self._uuid)] ✅ Work directory created: \(self._uniqueWorkDir.path)")
		} catch {
			Logger.misc.error("[\(self._uuid)] ❌ Failed to create work directory: \(error.localizedDescription)")
			throw error
		}
		
		let destinationURL = self._uniqueWorkDir.appendingPathComponent(self._ipa.lastPathComponent)
		Logger.misc.info("[\(self._uuid)] 🎯 Destination: \(destinationURL.path)")

		do {
			try self._fileManager.removeFileIfNeeded(at: destinationURL)
			Logger.misc.info("[\(self._uuid)] 🗑️ Cleaned up existing file if any")
		} catch {
			Logger.misc.error("[\(self._uuid)] ⚠️ Failed to remove existing file: \(error.localizedDescription)")
		}
		
		do {
			try self._fileManager.copyItem(at: self._ipa, to: destinationURL)
			self._ipa = destinationURL
			Logger.misc.info("[\(self._uuid)] ✅ File copied successfully to: \(self._ipa.path)")
		} catch {
			Logger.misc.error("[\(self._uuid)] ❌ Failed to copy file: \(error.localizedDescription)")
			throw error
		}
	}
	
	func extract() async throws {
		Logger.misc.info("[\(self._uuid)] 📦 Starting extraction process...")
		
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
					Logger.misc.info("[\(self._uuid)] 🔓 Unzipping file...")
					try Zip.unzipFile(
						self._ipa,
						destination: self._uniqueWorkDir,
						overwrite: true,
						password: nil,
						progress: { progress in
							if let download = download {
								DispatchQueue.main.async {
									download.unpackageProgress = progress
								}
							}
						}
					)
					
					self.uniqueWorkDirPayload = self._uniqueWorkDir.appendingPathComponent("Payload")
					Logger.misc.info("[\(self._uuid)] ✅ Extraction completed. Payload: \(self.uniqueWorkDirPayload?.path ?? "nil")")
					continuation.resume()
				} catch {
					Logger.misc.error("[\(self._uuid)] ❌ Extraction failed: \(error.localizedDescription)")
					continuation.resume(throwing: error)
				}
			}
		}
	}
	
	func move() async throws {
		Logger.misc.info("[\(self._uuid)] 📦 Starting move process...")
		
		guard let payloadURL = uniqueWorkDirPayload else {
			Logger.misc.error("[\(self._uuid)] ❌ Payload URL is nil!")
			throw ImportedFileHandlerError.payloadNotFound
		}
		
		let destinationURL = try await _directory()
		Logger.misc.info("[\(self._uuid)] 🎯 Moving from: \(payloadURL.path)")
		Logger.misc.info("[\(self._uuid)] 🎯 Moving to: \(destinationURL.path)")
		
		guard _fileManager.fileExists(atPath: payloadURL.path) else {
			Logger.misc.error("[\(self._uuid)] ❌ Payload does not exist at: \(payloadURL.path)")
			throw ImportedFileHandlerError.payloadNotFound
		}
		
		try _fileManager.moveItem(at: payloadURL, to: destinationURL)
		Logger.misc.info("[\(self._uuid)] ✅ Moved Payload to: \(destinationURL.path)")
		
		try? _fileManager.removeItem(at: _uniqueWorkDir)
		Logger.misc.info("[\(self._uuid)] 🗑️ Cleaned up work directory")
	}
	
	func addToDatabase() async throws {
		Logger.misc.info("[\(self._uuid)] 💾 Adding to database...")
		
		let app = try await _directory()
		
		guard let appUrl = _fileManager.getPath(in: app, for: "app") else {
			Logger.misc.error("[\(self._uuid)] ❌ Could not find .app bundle in: \(app.path)")
			return
		}
		
		Logger.misc.info("[\(self._uuid)] 📱 Found app at: \(appUrl.path)")
		
		let bundle = Bundle(url: appUrl)
		let uuid = self._uuid
		
		Storage.shared.addImported(
			uuid: _uuid,
			appName: bundle?.name,
			appIdentifier: bundle?.bundleIdentifier,
			appVersion: bundle?.version,
			appIcon: bundle?.iconFileName,
			fileHash: self._fileHash,
			fileName: self._fileName
		) { _ in
			Logger.misc.info("[\(self._uuid)] ✅ Added to database")
			
			// Send notification to open signing view with the UUID
			// Small delay to ensure CoreData FetchRequest has updated the UI
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
				NotificationCenter.default.post(
					name: Notification.Name("Feather.openSigningView"),
					object: nil,
					userInfo: ["uuid": uuid]
				)
			}
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
