//
//  SigningHandler.swift
//  Feather
//
//  Created by samara on 17.04.2025.
//

import Foundation
import Zsign

final class SigningHandler: NSObject {
	private let _fileManager = FileManager.default
	private let _uuid = UUID().uuidString
	private var _movedAppPath: URL?
	// using uuid string is the best way to find the
	// app we want to sign, it does not matter what
	// type of app it is
	private var _app: AppInfoPresentable
	private var _options: Options
	private let _uniqueWorkDir: URL
	
	init(app: AppInfoPresentable, options: Options = OptionsManager.shared.options) {
		self._app = app
		self._options = options
		self._uniqueWorkDir = _fileManager.temporaryDirectory
			.appendingPathComponent("FeatherSigning_\(_uuid)", isDirectory: true)
		super.init()
	}
	
	func copy() async throws {
		guard let appUrl = Storage.shared.getAppDirectory(for: _app) else {
			throw SigningFileHandlerError.appNotFound
		}
		
		if !_fileManager.fileExists(atPath: _uniqueWorkDir.path) {
			try _fileManager.createDirectory(at: _uniqueWorkDir, withIntermediateDirectories: true)
		}
		
		let movedAppURL = _uniqueWorkDir.appendingPathComponent(appUrl.lastPathComponent)
		
		print(appUrl)
		print(movedAppURL)
		
		try _fileManager.copyItem(at: appUrl, to: movedAppURL)
		_movedAppPath = movedAppURL
		print("[\(_uuid)] Moved Payload to: \(movedAppURL.path)")
	}
	
	func modify() async throws {
		guard let movedAppPath = _movedAppPath else {
			throw SigningFileHandlerError.appNotFound
		}
		
		guard
			let infoDictionary = NSDictionary(
				contentsOf: movedAppPath.appendingPathComponent("Info.plist")
			)!.mutableCopy() as? NSMutableDictionary
		else {
			throw SigningFileHandlerError.infoPlistNotFound
		}
		
		try await _modifyDict(using: infoDictionary, with: _options, to: movedAppPath)
		
		if let name = _options.appName {
			try await _modifyLocalesForName(name, for: movedAppPath)
		}
		
		if _options.removeWatchPlaceholder {
			try await _removePlaceholderWatch(for: movedAppPath)
		}
		
		try await _removeProvisioning(for: movedAppPath)
	}
	
	func move() async throws {
		guard let movedAppPath = _movedAppPath else {
			throw SigningFileHandlerError.appNotFound
		}
		
		var destinationURL = try await _directory()
		
		if !_fileManager.fileExists(atPath: destinationURL.path) {
			try _fileManager.createDirectory(at: destinationURL, withIntermediateDirectories: true)
		}
		
		destinationURL = destinationURL.appendingPathComponent(movedAppPath.lastPathComponent)
		
		try _fileManager.moveItem(at: movedAppPath, to: destinationURL)
		print("[\(_uuid)] Moved App to: \(destinationURL.path)")
		try? _fileManager.removeItem(at: _uniqueWorkDir)
	}
	
	func addToDatabase() async throws {
		Storage.shared.addSigned(uuid: _uuid) { _ in
			print("[\(self._uuid)] Added to database")
		}
	}
	
	private func _directory() async throws -> URL {
		// Documents/Feather/Signed/\(UUID)
		_fileManager.signed(_uuid)
	}
}

extension SigningHandler {
	private func _modifyDict(using infoDictionary: NSMutableDictionary, with options: Options, to app: URL) async throws {
		if options.fileSharing { infoDictionary.setObject(true, forKey: "UISupportsDocumentBrowser" as NSCopying) }
		if options.itunesFileSharing { infoDictionary.setObject(true, forKey: "UIFileSharingEnabled" as NSCopying) }
		if options.proMotion { infoDictionary.setObject(true, forKey: "CADisableMinimumFrameDurationOnPhone" as NSCopying) }
		if options.gameMode { infoDictionary.setObject(true, forKey: "GCSupportsGameMode" as NSCopying)}
		if options.ipadFullscreen { infoDictionary.setObject(true, forKey: "UIRequiresFullScreen" as NSCopying) }
		if options.removeSupportedDevices { infoDictionary.removeObject(forKey: "UISupportedDevices") }
		if options.removeURLScheme { infoDictionary.removeObject(forKey: "CFBundleURLTypes") }
		try infoDictionary.write(to: app.appendingPathComponent("Info.plist"))
	}
	
	private func _removePlaceholderWatch(for app: URL) async throws {
		let path = app.appendingPathComponent("com.apple.WatchPlaceholder")
		if _fileManager.fileExists(atPath: path.path) {
			try _fileManager.removeItem(at: path)
		}
	}
	
	#warning("add support for this")
	private func _removePlugIns(for app: URL) async throws {
		let path = app.appendingPathComponent("PlugIns")
		if _fileManager.fileExists(atPath: path.path) {
			try _fileManager.removeItem(at: path)
		}
	}
	
	private func _modifyLocalesForName(_ name: String, for app: URL) async throws {
		let localizationBundles = try _fileManager
			.contentsOfDirectory(at: app, includingPropertiesForKeys: nil)
			.filter { $0.pathExtension == "lproj" }
		
		localizationBundles.forEach { bundleURL in
			let plistURL = bundleURL.appendingPathComponent("InfoPlist.strings")
			
			guard
				_fileManager.fileExists(atPath: plistURL.path),
				let dictionary = NSMutableDictionary(contentsOf: plistURL)
			else {
				return
			}
			
			dictionary["CFBundleDisplayName"] = name
			dictionary.write(toFile: plistURL.path, atomically: true)
		}
	}
	
	private func _removeProvisioning(for app: URL) async throws {
		let provisioningFilePath = app.appendingPathComponent("embedded.mobileprovision")
		if _fileManager.fileExists(atPath: provisioningFilePath.path) {
			try _fileManager.removeItem(at: provisioningFilePath)
		}
	}

}

private enum SigningFileHandlerError: Error {
	case appNotFound
	case infoPlistNotFound
}
