//
//  AppSigner.swift
//  feather
//
//  Created by HAHALOSAH on 7/17/24.
//

import Foundation
import UIKit
import AlertKit

struct AppSigningOptions {
    var name: String
    var version: String
    var bundleId: String
    
    var uuid: String
	var injectionTool: String
    
    var removePlugins: Bool
    var forceFileSharing: Bool
    var removeSupportedDevices: Bool
    var removeURLScheme: Bool
	var forceProMotion: Bool
	
	var forceForceFullScreen: Bool
	var forceiTunesFileSharing: Bool
	var forceMinimumVersion: String
	var forceLightDarkAppearence: String
    
    var certificate: Certificate?
}

func signApp(options: AppSigningOptions, completion: @escaping (Bool) -> Void) {
	UIApplication.shared.isIdleTimerDisabled = true
    DispatchQueue(label: "Signing").async {
        let fileManager = FileManager.default
        let tmpDir = fileManager.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        do {
            try fileManager.copyItem(at: getDocumentsDirectory().appendingPathComponent("Apps/Unsigned").appendingPathComponent(options.uuid), to: tmpDir)
            let contents = try fileManager.contentsOfDirectory(at: tmpDir, includingPropertiesForKeys: [])
            if contents.isEmpty {
                DispatchQueue.main.async { completion(false) }
                return
            }
            let bundle = contents.first!
            let info = NSDictionary(contentsOf: bundle.appendingPathComponent("Info.plist"))!.mutableCopy() as! NSMutableDictionary
            if options.forceFileSharing { info.setObject(true, forKey: "UISupportsDocumentBrowser" as NSCopying) }
			if options.forceiTunesFileSharing { info.setObject(true, forKey: "UIFileSharingEnabled" as NSCopying) }
            if options.removeSupportedDevices { info.removeObject(forKey: "UISupportedDevices") }
            if options.removeURLScheme { info.removeObject(forKey: "CFBundleURLTypes") }
			if options.forceProMotion { info.setObject(true, forKey: "CADisableMinimumFrameDurationOnPhone" as NSCopying)}
			if options.forceForceFullScreen { info.setObject(true, forKey: "UIRequiresFullScreen" as NSCopying) }
			if options.forceMinimumVersion != "Automatic" { info.setObject(options.forceMinimumVersion, forKey: "MinimumOSVersion" as NSCopying) }
			if options.forceLightDarkAppearence != "Automatic" { info.setObject(options.forceLightDarkAppearence, forKey: "UIUserInterfaceStyle" as NSCopying)}
            try info.write(to: bundle.appendingPathComponent("Info.plist"))

			let certPath = CoreDataManager.shared.getCertifcatePath(source: options.certificate!)
			let provisionPath = certPath.appendingPathComponent("\(options.certificate?.provisionPath ?? "")").path
			let p12Path = certPath.appendingPathComponent("\(options.certificate?.p12Path ?? "")").path
			
            if zsign(bundle.path,
					 provisionPath,
					 p12Path,
					 options.certificate?.password ?? "",
					 options.bundleId,
					 options.name,
					 options.version
			) != 0 {
				Debug.shared.log(message: "You failed dumb fuck")
                DispatchQueue.main.async {
                    completion(false)
                }
                return
            }
			
            let signedUUID = UUID().uuidString
            try fileManager.createDirectory(at: getDocumentsDirectory().appendingPathComponent("Apps/Signed"), withIntermediateDirectories: true)
            let appPath = getDocumentsDirectory().appendingPathComponent("Apps/Signed").appendingPathComponent(signedUUID)
            try fileManager.moveItem(at: tmpDir, to: appPath)
            
            DispatchQueue.main.async {
				var iconURL = ""
                if let iconsDict = info["CFBundleIcons"] as? [String: Any],
                   let primaryIconsDict = iconsDict["CFBundlePrimaryIcon"] as? [String: Any],
                   let iconFiles = primaryIconsDict["CFBundleIconFiles"] as? [String],
                   let iconFileName = iconFiles.first {
                    iconURL = iconFileName
                }
				
				CoreDataManager.shared.addToSignedApps(
					version: options.version,
					name: options.name,
					bundleidentifier: options.bundleId,
					iconURL: iconURL,
					uuid: signedUUID,
					appPath: contents.first!.lastPathComponent
				) { 
					error in
					Debug.shared.log(message: "signApp: \(String(describing: error))", type: .critical)
					completion(false)
				}
                DispatchQueue.main.async {
                    let alertView = AlertAppleMusic17View(title: "Successfully signed \(options.name)", subtitle: nil, icon: .done)
                    if let viewController = UIApplication.shared.windows.first?.rootViewController {
                        alertView.present(on: viewController.view)
                    }
                }
				UIApplication.shared.isIdleTimerDisabled = false
                completion(true)
            }
        } catch {
			UIApplication.shared.isIdleTimerDisabled = false
			Debug.shared.log(message: "signApp: \(error)", type: .error)
            DispatchQueue.main.async {
                completion(false)
            }
        }
    }
}
