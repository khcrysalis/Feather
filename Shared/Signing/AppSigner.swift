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

struct AppSigningOptions {
    var name: String?
    var version: String?
    var bundleId: String?
	var iconURL: UIImage?
	
    var uuid: String
	var toInject: [URL]?
	var removeInjectPaths: [String]?
    
    var removePlugins: Bool?
    var forceFileSharing: Bool?
    var removeSupportedDevices: Bool?
    var removeURLScheme: Bool?
	var forceProMotion: Bool?
	
	var forceForceFullScreen: Bool?
	var forceiTunesFileSharing: Bool?
	var forceMinimumVersion: String?
	var forceLightDarkAppearence: String?
	
	var removeProvisioningFile: Bool?
	var removeWatchPlaceHolder: Bool?
    
    var certificate: Certificate?
}

func signInitialApp(options: AppSigningOptions, appPath: URL, completion: @escaping (Result<(URL, NSManagedObject), Error>) -> Void) {
	UIApplication.shared.isIdleTimerDisabled = true
	DispatchQueue(label: "Signing").async {
		let fileManager = FileManager.default
		let tmpDir = fileManager.temporaryDirectory.appendingPathComponent(UUID().uuidString)
		let tmpDirApp = tmpDir.appendingPathComponent(appPath.lastPathComponent)
		var iconURL = ""
		

		do {
			Debug.shared.log(message: "============================================")
			Debug.shared.log(message: "\(options)")
			Debug.shared.log(message: "============================================")
			try fileManager.createDirectory(at: tmpDir, withIntermediateDirectories: true)
			try fileManager.copyItem(at: appPath, to: tmpDirApp)
			
			if let info = NSDictionary(contentsOf: tmpDirApp.appendingPathComponent("Info.plist"))!.mutableCopy() as? NSMutableDictionary {
				try updateInfoPlist(infoDict: info, options: options, icon: options.iconURL, app: tmpDirApp)
				
				if let iconsDict = info["CFBundleIcons"] as? [String: Any],
				   let primaryIconsDict = iconsDict["CFBundlePrimaryIcon"] as? [String: Any],
				   let iconFiles = primaryIconsDict["CFBundleIconFiles"] as? [String],
				   let iconFileName = iconFiles.first {
					iconURL = iconFileName
				}
			}

			let handler = TweakHandler(urls: options.toInject ?? [], app: tmpDirApp)
			try handler.getInputFiles()

			if let removeInjectPaths = options.removeInjectPaths, !removeInjectPaths.isEmpty {
				if let appexe = try TweakHandler.findExecutable(at: tmpDirApp) {
					_ = uninstallDylibs(filePath: appexe.path, dylibPaths: removeInjectPaths)
				}
			}

			try updatePlugIns(options: options, app: tmpDirApp)
			try removeDumbAssPlaceHolderExtension(options: options, app: tmpDirApp)
			try updateMobileProvision(app: tmpDirApp)

			let certPath = try CoreDataManager.shared.getCertifcatePath(source: options.certificate)
			let provisionPath = certPath.appendingPathComponent("\(options.certificate?.provisionPath ?? "")").path
			let p12Path = certPath.appendingPathComponent("\(options.certificate?.p12Path ?? "")").path

			Debug.shared.log(message: "🦋 Start Signing 🦋")

			try signAppWithZSign(tmpDirApp: tmpDirApp, certPaths: (provisionPath, p12Path), password: options.certificate?.password ?? "", options: options)

			Debug.shared.log(message: "🦋 End Signing 🦋")

			let signedUUID = UUID().uuidString
			try fileManager.createDirectory(at: getDocumentsDirectory().appendingPathComponent("Apps/Signed"), withIntermediateDirectories: true)
			let signedPath = getDocumentsDirectory().appendingPathComponent("Apps/Signed").appendingPathComponent(signedUUID)
			try fileManager.moveItem(at: tmpDir, to: signedPath)

			DispatchQueue.main.async {
				var signedAppObject: NSManagedObject? = nil
				
				CoreDataManager.shared.addToSignedApps(
					version: options.version!,
					name: options.name!,
					bundleidentifier: options.bundleId!,
					iconURL: iconURL,
					uuid: signedUUID,
					appPath: appPath.lastPathComponent,
					timeToLive: options.certificate?.certData?.expirationDate ?? Date(),
					teamName: options.certificate?.certData?.name ?? ""
				) { result in
					

					switch result {
					case .success(let signedApp):
						signedAppObject = signedApp
					case .failure(let error):
						Debug.shared.log(message: "signApp: \(error)", type: .error)
						completion(.failure(error))
					}
				}
				
				Debug.shared.log(message: String.localized("SUCCESS_SIGNED", arguments: "\(options.name ?? String.localized("UNKNOWN"))"), type: .success)
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
			
			try signAppWithZSign(tmpDirApp: appPath, certPaths: (provisionPath, p12Path), password: certificate.password ?? "", options: nil)
			
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

private func signAppWithZSign(tmpDirApp: URL, certPaths: (provisionPath: String, p12Path: String), password: String, options: AppSigningOptions?) throws {
	if zsign(tmpDirApp.path,
			 certPaths.provisionPath,
			 certPaths.p12Path,
			 password,
			 options?.bundleId ?? "",
			 options?.name ?? "",
			 options?.version ?? "",
			 options?.removeProvisioningFile ?? false
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


func updatePlugIns(options: AppSigningOptions, app: URL) throws {
	if options.removePlugins! {
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

func removeDumbAssPlaceHolderExtension(options: AppSigningOptions, app: URL) throws {
	if options.removeWatchPlaceHolder! {
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

func updateInfoPlist(infoDict: NSMutableDictionary, options: AppSigningOptions, icon: UIImage?, app: URL) throws {
	if (options.iconURL != nil) {
		
		let imageSizes = [
			(width: 120, height: 120, name: "FRIcon60x60@2x.png"),
			(width: 152, height: 152, name: "FRIcon76x76@2x~ipad.png")
		]
		
		for imageSize in imageSizes {
			let resizedImage = options.iconURL!.resize(imageSize.width, imageSize.height)
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
		Debug.shared.log(message: "updateInfoPlist.updateicon: Does not include an icon! Will not do this.")
	}
	
	if infoDict.value(forKey: "CFBundleDisplayName") as? String != options.name {
		try updateLocalizedInfoPlist(in: app, newDisplayName: options.name!)
	}
	
	if options.forceFileSharing! { infoDict.setObject(true, forKey: "UISupportsDocumentBrowser" as NSCopying) }
	if options.forceiTunesFileSharing! { infoDict.setObject(true, forKey: "UIFileSharingEnabled" as NSCopying) }
	if options.removeSupportedDevices! { infoDict.removeObject(forKey: "UISupportedDevices") }
	if options.removeURLScheme! { infoDict.removeObject(forKey: "CFBundleURLTypes") }
	if options.forceProMotion! { infoDict.setObject(true, forKey: "CADisableMinimumFrameDurationOnPhone" as NSCopying)}
	if options.forceForceFullScreen! { infoDict.setObject(true, forKey: "UIRequiresFullScreen" as NSCopying) }
	if options.forceMinimumVersion! != "Automatic" { infoDict.setObject(options.forceMinimumVersion!, forKey: "MinimumOSVersion" as NSCopying) }
	if options.forceLightDarkAppearence! != "Automatic" { infoDict.setObject(options.forceLightDarkAppearence!, forKey: "UIUserInterfaceStyle" as NSCopying)}
	try infoDict.write(to: app.appendingPathComponent("Info.plist"))
}

func updateLocalizedInfoPlist(in appDirectory: URL, newDisplayName: String) throws {
	let fileManager = FileManager.default
	let contents = try fileManager.contentsOfDirectory(at: appDirectory, includingPropertiesForKeys: nil)
	let localizationBundles = contents.filter { $0.pathExtension == "lproj" }
	
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
}
