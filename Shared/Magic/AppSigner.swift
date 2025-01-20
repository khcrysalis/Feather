//
//  AppSigner.swift
//  feather
//
//  Created by HAHALOSAH on 7/17/24.
//  Copyright (c) 2024 Samara M (khcrysalis)
//

import Foundation
import UIKit
import AlertKit
import CoreData

func signInitialApp(bundle: BundleOptions, mainOptions: SigningMainDataWrapper, signingOptions: SigningDataWrapper, appPath: URL, completion: @escaping (Result<(URL, NSManagedObject), Error>) -> Void) {
	UIApplication.shared.isIdleTimerDisabled = true
	DispatchQueue(label: "Signing").async {
		let fileManager = FileManager.default
		let tmpDir = fileManager.temporaryDirectory.appendingPathComponent(UUID().uuidString)
		let tmpDirApp = tmpDir.appendingPathComponent(appPath.lastPathComponent)
		var iconURL = ""
		

		do {
			Debug.shared.log(message: "============================================")
			Debug.shared.log(message: "\(mainOptions.mainOptions)")
			Debug.shared.log(message: "============================================")
			Debug.shared.log(message: "\(signingOptions.signingOptions)")
			Debug.shared.log(message: "============================================")
			try fileManager.createDirectory(at: tmpDir, withIntermediateDirectories: true)
			try fileManager.copyItem(at: appPath, to: tmpDirApp)
			
			if let info = NSDictionary(contentsOf: tmpDirApp.appendingPathComponent("Info.plist"))!.mutableCopy() as? NSMutableDictionary {
				try updateInfoPlist(infoDict: info, main: mainOptions, options: signingOptions, icon: mainOptions.mainOptions.iconURL, app: tmpDirApp)
				
				if let iconsDict = info["CFBundleIcons"] as? [String: Any],
				   let primaryIconsDict = iconsDict["CFBundlePrimaryIcon"] as? [String: Any],
				   let iconFiles = primaryIconsDict["CFBundleIconFiles"] as? [String],
				   let iconFileName = iconFiles.first {
					iconURL = iconFileName
				}
			}

			let handler = TweakHandler(urls: signingOptions.signingOptions.toInject, app: tmpDirApp)
			try handler.getInputFiles()

			if !mainOptions.mainOptions.removeInjectPaths.isEmpty {
				if let appexe = try? TweakHandler.findExecutable(at: tmpDirApp) {
					_ = uninstallDylibs(filePath: appexe.path, dylibPaths: mainOptions.mainOptions.removeInjectPaths)
				}
			}

			try updatePlugIns(options: signingOptions, app: tmpDirApp)
			try removeDumbAssPlaceHolderExtension(options: signingOptions, app: tmpDirApp)
			try updateMobileProvision(app: tmpDirApp)

			let certPath = try CoreDataManager.shared.getCertifcatePath(source: mainOptions.mainOptions.certificate)
			let provisionPath = certPath.appendingPathComponent("\(mainOptions.mainOptions.certificate?.provisionPath ?? "")").path
			let p12Path = certPath.appendingPathComponent("\(mainOptions.mainOptions.certificate?.p12Path ?? "")").path

			Debug.shared.log(message: "🦋 Start Signing 🦋")

			try signAppWithZSign(tmpDirApp: tmpDirApp, certPaths: (provisionPath, p12Path), password: mainOptions.mainOptions.certificate?.password ?? "", main: mainOptions, options: signingOptions)

			Debug.shared.log(message: "🦋 End Signing 🦋")

			let signedUUID = UUID().uuidString
			try fileManager.createDirectory(at: getDocumentsDirectory().appendingPathComponent("Apps/Signed"), withIntermediateDirectories: true)
			let signedPath = getDocumentsDirectory().appendingPathComponent("Apps/Signed").appendingPathComponent(signedUUID)
			try fileManager.moveItem(at: tmpDir, to: signedPath)

			DispatchQueue.main.async {
				var signedAppObject: NSManagedObject? = nil
				
				CoreDataManager.shared.addToSignedApps(
					version: (mainOptions.mainOptions.version ?? bundle.version)!,
					name: (mainOptions.mainOptions.name ?? bundle.name)!,
					bundleidentifier: (mainOptions.mainOptions.bundleId ?? bundle.bundleId)!,
					iconURL: iconURL,
					uuid: signedUUID,
					appPath: appPath.lastPathComponent,
					timeToLive: mainOptions.mainOptions.certificate?.certData?.expirationDate ?? Date(),
					teamName: mainOptions.mainOptions.certificate?.certData?.name ?? "",
					originalSourceURL: bundle.sourceURL
				) { result in
					

					switch result {
					case .success(let signedApp):
						signedAppObject = signedApp
					case .failure(let error):
						Debug.shared.log(message: "signApp: \(error)", type: .error)
						completion(.failure(error))
					}
				}
				
				Debug.shared.log(message: String.localized("SUCCESS_SIGNED", arguments: "\((mainOptions.mainOptions.name ?? bundle.name) ?? String.localized("UNKNOWN"))"), type: .success)
				Debug.shared.log(message: "============================================")
				
				UIApplication.shared.isIdleTimerDisabled = false
				completion(.success((signedPath, signedAppObject!)))
			}
		} catch {
			DispatchQueue.main.async {
				UIApplication.shared.isIdleTimerDisabled = false
				Debug.shared.log(message: "signApp: \(error)", type: .critical)
				completion(.failure(error))
			}
		}
	}
}


func resignApp(certificate: Certificate, appPath: URL, completion: @escaping (Bool) -> Void) {
	UIApplication.shared.isIdleTimerDisabled = true
	DispatchQueue(label: "Resigning").async {
		do {
            let certPath = try CoreDataManager.shared.getCertifcatePath(source: certificate)
			let provisionPath = certPath.appendingPathComponent("\(certificate.provisionPath ?? "")").path
			let p12Path = certPath.appendingPathComponent("\(certificate.p12Path ?? "")").path
			
			Debug.shared.log(message: "============================================")
			Debug.shared.log(message: "🦋 Start Resigning 🦋")
			
			try signAppWithZSign(tmpDirApp: appPath, certPaths: (provisionPath, p12Path), password: certificate.password ?? "")
			
			Debug.shared.log(message: "🦋 End Resigning 🦋")
			DispatchQueue.main.async {
				UIApplication.shared.isIdleTimerDisabled = false
				Debug.shared.log(message: String.localized("SUCCESS_RESIGN"), type: .success)
			}
			Debug.shared.log(message: "============================================")
			completion(true)
		} catch {
			Debug.shared.log(message: "\(error)", type: .warning)
			completion(false)
		}
	}
}

private func signAppWithZSign(tmpDirApp: URL, certPaths: (provisionPath: String, p12Path: String), password: String, main: SigningMainDataWrapper? = nil, options: SigningDataWrapper? = nil) throws {
	if zsign(tmpDirApp.path,
			 certPaths.provisionPath,
			 certPaths.p12Path,
			 password,
			 main?.mainOptions.bundleId ?? "",
			 main?.mainOptions.name ?? "",
			 main?.mainOptions.version ?? "",
			 options?.signingOptions.removeProvisioningFile ?? true
	) != 0 {
		throw NSError(domain: "AppSigningErrorDomain", code: 1, userInfo: [NSLocalizedDescriptionKey: String.localized("ERROR_ZSIGN_FAILED")])
	}
}

func injectDylib(filePath: String, dylibPath: String, weakInject: Bool) -> Bool {
	let bCreate: Bool = false
	let success = InjectDyLib(filePath, dylibPath, weakInject, bCreate)
	return success
}

func changeDylib(filePath: String, oldPath: String, newPath: String) -> Bool {
	let success = ChangeDylibPath(filePath, oldPath, newPath)
	return success
}

func updateMobileProvision(app: URL) throws {
	let provisioningFilePath = app.appendingPathComponent("embedded.mobileprovision")
	if FileManager.default.fileExists(atPath: provisioningFilePath.path) {
		do {
			try FileManager.default.removeItem(at: provisioningFilePath)
			Debug.shared.log(message: "Embedded.mobileprovision file removed successfully!")
		} catch {
			throw error
		}
	} else {
		Debug.shared.log(message: "Could not find any mobileprovision to remove. ")
	}
}

func listDylibs(filePath: String) -> [String]? {
	let dylibPathsArray = NSMutableArray()

	let success = ListDylibs(filePath, dylibPathsArray)

	if success {
		let dylibPaths = dylibPathsArray as! [String]
		return dylibPaths
	} else {
		Debug.shared.log(message: "Failed to list dylibs.")
		return nil
	}
}

func uninstallDylibs(filePath: String, dylibPaths: [String]) -> Bool {
	return UninstallDylibs(filePath, dylibPaths)
}


func updatePlugIns(options: SigningDataWrapper, app: URL) throws {
	if options.signingOptions.removePlugins {
		let filemanager = FileManager.default
		let path = app.appendingPathComponent("PlugIns")
		if filemanager.fileExists(atPath: path.path) {
			do {
				try filemanager.removeItem(at: path)
				Debug.shared.log(message: "Removed PlugIns!")
			} catch {
				throw error
			}
		} else {
			Debug.shared.log(message: "Could not find any PlugIns to remove.")
		}
	}
}

func removeDumbAssPlaceHolderExtension(options: SigningDataWrapper, app: URL) throws {
	if options.signingOptions.removeWatchPlaceHolder {
		let filemanager = FileManager.default
		let path = app.appendingPathComponent("com.apple.WatchPlaceholder")
		if filemanager.fileExists(atPath: path.path) {
			do {
				try filemanager.removeItem(at: path)
				Debug.shared.log(message: "Removed placeholder watch app!")
			} catch {
				throw error
			}
		} else {
			Debug.shared.log(message: "Placeholder watch app not found.")
		}
	}
}

func updateInfoPlist(infoDict: NSMutableDictionary, main: SigningMainDataWrapper, options: SigningDataWrapper, icon: UIImage?, app: URL) throws {
	if (main.mainOptions.iconURL != nil) {
		
		let imageSizes = [
			(width: 120, height: 120, name: "FRIcon60x60@2x.png"),
			(width: 152, height: 152, name: "FRIcon76x76@2x~ipad.png")
		]
		
		for imageSize in imageSizes {
			let resizedImage = main.mainOptions.iconURL!.resize(imageSize.width, imageSize.height)
			let imageData = resizedImage.pngData()
			let fileURL = app.appendingPathComponent(imageSize.name)
			
			do {
				try imageData?.write(to: fileURL)
				Debug.shared.log(message: "Saved image to: \(fileURL)")
			} catch {
				Debug.shared.log(message: "Failed to save image: \(imageSize.name), error: \(error)")
				throw error
			}
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
		
		infoDict["CFBundleIcons"] = cfBundleIcons
		infoDict["CFBundleIcons~ipad"] = cfBundleIconsIpad
		
	} else {
		Debug.shared.log(message: "updateInfoPlist.updateicon: Does not include an icon, skipping!")
	}
	
	if options.signingOptions.forceTryToLocalize && (main.mainOptions.name != nil) {
		if let displayName = infoDict.value(forKey: "CFBundleDisplayName") as? String {
			if displayName != main.mainOptions.name {
				updateLocalizedInfoPlist(in: app, newDisplayName: main.mainOptions.name!)
			}
		} else {
			Debug.shared.log(message: "updateInfoPlist.displayName: CFBundleDisplayName not found, skipping!")
		}
	}

	if options.signingOptions.forceFileSharing { infoDict.setObject(true, forKey: "UISupportsDocumentBrowser" as NSCopying) }
	if options.signingOptions.forceiTunesFileSharing { infoDict.setObject(true, forKey: "UIFileSharingEnabled" as NSCopying) }
	if options.signingOptions.removeSupportedDevices { infoDict.removeObject(forKey: "UISupportedDevices") }
	if options.signingOptions.removeURLScheme { infoDict.removeObject(forKey: "CFBundleURLTypes") }
	if options.signingOptions.forceProMotion { infoDict.setObject(true, forKey: "CADisableMinimumFrameDurationOnPhone" as NSCopying)}
	if options.signingOptions.forceGameMode { infoDict.setObject(true, forKey: "GCSupportsGameMode" as NSCopying)}
	if options.signingOptions.forceForceFullScreen { infoDict.setObject(true, forKey: "UIRequiresFullScreen" as NSCopying) }
	if options.signingOptions.forceMinimumVersion != "Automatic" { infoDict.setObject(options.signingOptions.forceMinimumVersion, forKey: "MinimumOSVersion" as NSCopying) }
	if options.signingOptions.forceLightDarkAppearence != "Automatic" { infoDict.setObject(options.signingOptions.forceLightDarkAppearence, forKey: "UIUserInterfaceStyle" as NSCopying)}
	try infoDict.write(to: app.appendingPathComponent("Info.plist"))
}

func updateLocalizedInfoPlist(in appDirectory: URL, newDisplayName: String) {
	let fileManager = FileManager.default
	do {
		let contents = try fileManager.contentsOfDirectory(at: appDirectory, includingPropertiesForKeys: nil)
		let localizationBundles = contents.filter { $0.pathExtension == "lproj" }
		
		guard !localizationBundles.isEmpty else {
			Debug.shared.log(message: "No .lproj directories found in \(appDirectory.path), skipping!")
			return
		}
		
		for localizationBundle in localizationBundles {
			let infoPlistStringsURL = localizationBundle.appendingPathComponent("InfoPlist.strings")
			
			if fileManager.fileExists(atPath: infoPlistStringsURL.path) {
				var localizedStrings = try String(contentsOf: infoPlistStringsURL, encoding: .utf8)
				let localizedDict = NSDictionary(contentsOf: infoPlistStringsURL) as! [String: String]
				
				if localizedDict["CFBundleDisplayName"] != newDisplayName {
					localizedStrings = localizedStrings.replacingOccurrences(of: localizedDict["CFBundleDisplayName"] ?? "", with: newDisplayName)
					try localizedStrings.write(to: infoPlistStringsURL, atomically: true, encoding: .utf8)
					Debug.shared.log(message: "Updated CFBundleDisplayName in \(infoPlistStringsURL.path)")
				}
			}
		}
	} catch {
		Debug.shared.log(message: "Unable to localize, skipping!", type: .debug)
	}
}
