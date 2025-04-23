//
//  ArchiveHandler.swift
//  Feather
//
//  Created by samara on 22.04.2025.
//

import Foundation
import UIKit.UIApplication
import Zip

final class ArchiveHandler: NSObject {
	private let _fileManager = FileManager.default
	private let _uuid = UUID().uuidString
	private var _payloadUrl: URL?
	private var _ipaUrl: URL?
	
	private var _app: AppInfoPresentable
	private let _uniqueWorkDir: URL
	
	init(app: AppInfoPresentable) {
		self._app = app
		self._uniqueWorkDir = _fileManager.temporaryDirectory
			.appendingPathComponent("FeatherInstall_\(_uuid)", isDirectory: true)
		
		super.init()
	}
	
	func move() async throws {
		guard let appUrl = Storage.shared.getAppDirectory(for: _app) else {
			throw SigningFileHandlerError.appNotFound
		}
		
		let payloadUrl = _uniqueWorkDir.appendingPathComponent("Payload")
		let movedAppURL = payloadUrl.appendingPathComponent(appUrl.lastPathComponent)
		
		if !_fileManager.fileExists(atPath: _uniqueWorkDir.path) {
			try _fileManager.createDirectory(
				at: payloadUrl,
				withIntermediateDirectories: true
			)
		}
		
		try _fileManager.copyItem(at: appUrl, to: movedAppURL)
		_payloadUrl = payloadUrl
	}
	
	func archive() async throws -> URL {
		guard let payloadUrl = _payloadUrl else {
			throw SigningFileHandlerError.appNotFound
		}
		
		let zipUrl = _uniqueWorkDir.appendingPathComponent("Archive.zip")
		let ipaUrl = _uniqueWorkDir.appendingPathComponent("Archive.ipa")
		
		try Zip.zipFiles(
			paths: [payloadUrl],
			zipFilePath: zipUrl,
			password: nil,
			compression: ZipCompression.allCases[ArchiveHandler.getCompressionLevel()],
		progress: { progress in
			print("[\(self._uuid)] Zip progress: \(progress)")
		})
		
		try _fileManager.moveItem(at: zipUrl, to: ipaUrl)
		_ipaUrl = ipaUrl
		return ipaUrl
	}
	
	func moveToArchiveAndOpen(_ package: URL) async throws {
		let appendingString = "\(_app.name!)_\(_app.version!)_\(Int(Date().timeIntervalSince1970)).ipa"
		let dest = _fileManager.archives.appendingPathComponent(appendingString)
		
		try? _fileManager.moveItem(
			at: package,
			to: dest
		)
		
		await MainActor.run {
			UIApplication.shared.open(
				FileManager.default.archives.toSharedDocumentsURL()!,
				options: [:]
			)
		}
	}
	
	static func getCompressionLevel() -> Int {
		UserDefaults.standard.integer(forKey: "Feather.compressionLevel")
	}
}
