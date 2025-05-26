//
//  AppFileHandler 2.swift
//  Feather
//
//  Created by İsmail Carlık on 25.05.2025.
//

import Foundation
import Zip
import SwiftUICore
import OSLog

final class AppBundleHandler: NSObject, @unchecked Sendable {
	private let _fileManager = FileManager.default
	private let _uuid = UUID().uuidString
	private let _uniqueWorkDir: URL

	private var _app: URL
	private let _install: Bool
	private let _download: Download?
	
	init(
		file app: URL,
		install: Bool = false,
		download: Download? = nil
	) {
		self._app = app
		self._install = install
		self._download = download
        self._uniqueWorkDir = _fileManager.unsigned(_uuid)
		super.init()
		Logger.misc.debug("Import initiated for: \(self._app.lastPathComponent) with ID: \(self._uuid)")
	}
	
	func copy() async throws {
		try _fileManager.createDirectoryIfNeeded(at: _uniqueWorkDir)
		
        let destinationURL = _uniqueWorkDir.appendingPathComponent(_app.lastPathComponent, conformingTo: .application)

		try _fileManager.removeFileIfNeeded(at: destinationURL)
		
		try _fileManager.copyItem(at: _app, to: destinationURL)
		_app = destinationURL
		Logger.misc.info("[\(self._uuid)] File copied to: \(self._app.path)")
	}
    
	func addToDatabase() async throws {
		//let app = try await _directory()
		
		//guard let appUrl = _fileManager.getPath(in: app, for: "app") else {
		//	return
		//}
		
		let bundle = Bundle(url: _app)
		
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
