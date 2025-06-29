//
//  SigningHandler.swift
//  Feather
//
//  Created by samara on 17.04.2025.
//

import Foundation
import Zsign
import UIKit
import OSLog

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
	// the options struct is not gonna decode these so
	// we're just going to do this. If appicon is not
	// specified, we're not going to modify the app
	// icon. If the cert pair is not there, fallback
	// to adhoc signing (if the option is on, otherwise
	// throw an error
	var appIcon: UIImage?
	var appCertificate: CertificatePair?
	
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

		try _fileManager.createDirectoryIfNeeded(at: _uniqueWorkDir)
		
		let movedAppURL = _uniqueWorkDir.appendingPathComponent(appUrl.lastPathComponent)
		
		try _fileManager.copyItem(at: appUrl, to: movedAppURL)
		_movedAppPath = movedAppURL
		Logger.misc.info("[\(self._uuid)] Moved Payload to: \(movedAppURL.path)")
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
		
		if let icon = appIcon {
			try await _modifyDict(using: infoDictionary, for: icon, to: movedAppPath)
		}
		
		if let name = _options.appName {
			try await _modifyLocalesForName(name, for: movedAppPath)
		}
		
		if !_options.removeFiles.isEmpty {
			try await _removeFiles(for: movedAppPath, from: _options.removeFiles)
		}
		
		try await _removePresetFiles(for: movedAppPath)
		try await _removeWatchIfNeeded(for: movedAppPath)
		
		if _options.experiment_supportLiquidGlass {
			try await _locateMachosAndChangeToSDK26(for: movedAppPath)
		}
		
		if _options.experiment_replaceSubstrateWithEllekit {
			try await _inject(for: movedAppPath, with: _options)
		} else {
			if !_options.injectionFiles.isEmpty {
				try await _inject(for: movedAppPath, with: _options)
			}
		}
		
		// iOS "26" (19) needs special treatment
		if #available(iOS 19, *) {
			try await _locateMachosAndFixupArm64eSlice(for: movedAppPath)
		}
		
		let handler = ZsignHandler(appUrl: movedAppPath, options: _options, cert: appCertificate)
		try await handler.disinject()
		
		if
			_options.signingOption == Options.signingOptionValues[0],
			appCertificate != nil
		{
			try await handler.sign()
		} else if _options.signingOption == Options.signingOptionValues[1] {
			try await handler.adhocSign()
		} else {
			throw SigningFileHandlerError.missingCertifcate
		}
		
	}
	
	func move() async throws {
		guard let movedAppPath = _movedAppPath else {
			throw SigningFileHandlerError.appNotFound
		}
		
		var destinationURL = try await _directory()
		
		try _fileManager.createDirectoryIfNeeded(at: destinationURL)
		
		destinationURL = destinationURL.appendingPathComponent(movedAppPath.lastPathComponent)
		
		try _fileManager.moveItem(at: movedAppPath, to: destinationURL)
		Logger.misc.info("[\(self._uuid)] Moved App to: \(destinationURL.path)")
		
		try? _fileManager.removeItem(at: _uniqueWorkDir)
	}
	
	func addToDatabase() async throws {
		let app = try await _directory()
		
		guard let appUrl = _fileManager.getPath(in: app, for: "app") else {
			return
		}
		
		let bundle = Bundle(url: appUrl)
		
		Storage.shared.addSigned(
			uuid: _uuid,
			certificate: _options.signingOption != Options.signingOptionValues[0] ? nil : appCertificate,
			appName: bundle?.name,
			appIdentifier: bundle?.bundleIdentifier,
			appVersion: bundle?.version,
			appIcon: bundle?.iconFileName
		) { _ in
			Logger.signing.info("[\(self._uuid)] Added to database")
		}
	}
	
	private func _directory() async throws -> URL {
		// Documents/Feather/Signed/\(UUID)
		_fileManager.signed(_uuid)
	}
	
	func clean() async throws {
		try _fileManager.removeFileIfNeeded(at: _uniqueWorkDir)
	}
}

extension SigningHandler {
	private func _modifyDict(using infoDictionary: NSMutableDictionary, with options: Options, to app: URL) async throws {
		if options.fileSharing { infoDictionary.setObject(true, forKey: "UISupportsDocumentBrowser" as NSCopying) }
		if options.itunesFileSharing { infoDictionary.setObject(true, forKey: "UIFileSharingEnabled" as NSCopying) }
		if options.proMotion { infoDictionary.setObject(true, forKey: "CADisableMinimumFrameDurationOnPhone" as NSCopying) }
		if options.gameMode { infoDictionary.setObject(true, forKey: "GCSupportsGameMode" as NSCopying)}
		if options.ipadFullscreen { infoDictionary.setObject(true, forKey: "UIRequiresFullScreen" as NSCopying) }
		if options.removeURLScheme { infoDictionary.removeObject(forKey: "CFBundleURLTypes") }
		
		// these are for picker arrays, we check if the default option is named "Default" before applying
		if options.appAppearance != Options.defaultOptions.appAppearance {
			infoDictionary.setObject(options.appAppearance, forKey: "UIUserInterfaceStyle" as NSCopying)
		}
		if options.minimumAppRequirement != Options.defaultOptions.minimumAppRequirement {
			infoDictionary.setObject(options.minimumAppRequirement, forKey: "MinimumOSVersion" as NSCopying)
		}
		
		// useless crap
		if infoDictionary["UISupportedDevices"] != nil {
			infoDictionary.removeObject(forKey: "UISupportedDevices")
		}
		
		try infoDictionary.write(to: app.appendingPathComponent("Info.plist"))
	}
	
	private func _modifyDict(using infoDictionary: NSMutableDictionary, for image: UIImage, to app: URL) async throws {
		let imageSizes = [
			(width: 120, height: 120, name: "FRIcon60x60@2x.png"),
			(width: 152, height: 152, name: "FRIcon76x76@2x~ipad.png")
		]
		
		for imageSize in imageSizes {
			let resizedImage = image.resize(imageSize.width, imageSize.height)
			let imageData = resizedImage.pngData()
			let fileURL = app.appendingPathComponent(imageSize.name)
			
			try imageData?.write(to: fileURL)
		}
		
		let cfBundleIcons: [String: Any] = [
			"CFBundlePrimaryIcon": [
				"CFBundleIconFiles": ["FRIcon60x60"],
				"CFBundleIconName": "FRIcon"
			]
		]
		
		let cfBundleIconsIpad: [String: Any] = [
			"CFBundlePrimaryIcon": [
				"CFBundleIconFiles": ["FRIcon60x60", "FRIcon76x76"],
				"CFBundleIconName": "FRIcon"
			]
		]
		
		infoDictionary["CFBundleIcons"] = cfBundleIcons
		infoDictionary["CFBundleIcons~ipad"] = cfBundleIconsIpad
		
		try infoDictionary.write(to: app.appendingPathComponent("Info.plist"))
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
	
	private func _removePresetFiles(for app: URL) async throws {
		var files = [
			"embedded.mobileprovision", // Remove this because zsign doesn't replace it
			"com.apple.WatchPlaceholder", // Useless
			"SignedByEsign" // Useless
		].map {
			app.appendingPathComponent($0)
		}
		
		await files += try _locateCodeSignatureDirectories(for: app)
		
		for file in files {
			try _fileManager.removeFileIfNeeded(at: file)
		}
	}
	
	// horrible edge-case
	private func _removeWatchIfNeeded(for app: URL) async throws {
		let watchDir = app.appendingPathComponent("Watch")
		guard _fileManager.fileExists(atPath: watchDir.path) else { return }
		
		let contents = try _fileManager.contentsOfDirectory(at: watchDir, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])
		
		for app in contents where app.pathExtension == "app" {
			let infoPlist = app.appendingPathComponent("Info.plist")
			if !_fileManager.fileExists(atPath: infoPlist.path) {
				try? _fileManager.removeItem(at: app)
			}
		}
	}
	
	private func _removeFiles(for app: URL, from appendingComponent: [String]) async throws {
		let filesToRemove = appendingComponent.map {
			app.appendingPathComponent($0)
		}
		
		for url in filesToRemove {
			try _fileManager.removeFileIfNeeded(at: url)
		}
	}
	
	private func _inject(for app: URL, with options: Options) async throws {
		let handler = TweakHandler(app: app, options: options)
		try await handler.getInputFiles()
	}
	
	private func _locateMachosAndChangeToSDK26(for app: URL) async throws {
		if let url = Bundle(url: app)?.executableURL {
			LCPatchMachOForSDK26(app.appendingPathComponent(url.relativePath).relativePath)
		}
	}
	
	private func _locateCodeSignatureDirectories(for app: URL) async throws -> [URL] {
		_enumerateFiles(at: app) { $0.hasSuffix("_CodeSignature") }
	}
	
	@available(iOS 19, *)
	private func _locateMachosAndFixupArm64eSlice(for app: URL) async throws {
		let machoFiles = _enumerateFiles(at: app) {
			$0.hasSuffix(".dylib") || $0.hasSuffix(".framework")
		}
		
		for fileURL in machoFiles {
			switch fileURL.pathExtension {
			case "dylib":
				LCPatchMachOFixupARM64eSlice(fileURL.path)
			case "framework":
				if
					let bundle = Bundle(url: fileURL),
					let execURL = bundle.executableURL
				{
					LCPatchMachOFixupARM64eSlice(execURL.path)
				}
			default:
				continue
			}
		}
	}
	
	private func _enumerateFiles(at base: URL, where predicate: (String) -> Bool) -> [URL] {
		guard let fileEnum = _fileManager.enumerator(atPath: base.path()) else {
			return []
		}
		
		var results: [URL] = []
		
		while let file = fileEnum.nextObject() as? String {
			if predicate(file) {
				results.append(base.appendingPathComponent(file))
			}
		}
		
		return results
	}
}

enum SigningFileHandlerError: Error, LocalizedError {
	case appNotFound
	case infoPlistNotFound
	case missingCertifcate
	case disinjectFailed
	case signFailed
	
	var errorDescription: String? {
		switch self {
		case .appNotFound: "Unable to locate bundle path."
		case .infoPlistNotFound: "Unable to locate info.plist path."
		case .missingCertifcate: "No certificate was specified."
		case .disinjectFailed: "Removing mach-O load paths failed."
		case .signFailed: "Signing failed."
		}
	}
}
