//
//  AppSigner.swift
//  feather
//
//  Created by HAHALOSAH on 7/17/24.
//

import Foundation
import UIKit

struct AppSigningOptions {
    var name: String
    var version: String
    var bundleId: String
    
    var uuid: String
    
    var removePlugins: Bool
    var forceFileSharing: Bool
    var removeSupportedDevices: Bool
    var removeURLScheme: Bool
    
    var certificate: Certificate?
}

func signApp(options: AppSigningOptions, completion: @escaping (Bool) -> Void) {
	
    DispatchQueue(label: "Signing").async {
        let fileManager = FileManager.default
        let tmpDir = fileManager.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        do {
            
            try fileManager.copyItem(at: getDocumentsDirectory().appendingPathComponent("Apps/Unsigned").appendingPathComponent(options.uuid), to: tmpDir)
            let contents = try fileManager.contentsOfDirectory(at: tmpDir, includingPropertiesForKeys: [])
            if contents.isEmpty {
                DispatchQueue.main.async {
                    completion(false)
                }
                return
            }
            let bundle = contents.first!
            let info = NSDictionary(contentsOf: bundle.appendingPathComponent("Info.plist"))!.mutableCopy() as! NSMutableDictionary
            if options.forceFileSharing {
                info.setObject(true, forKey: "UIFileSharingEnabled" as NSCopying)
            }
            if options.removeSupportedDevices {
                info.removeObject(forKey: "UISupportedDevices")
            }
            if options.removeURLScheme {
                info.removeObject(forKey: "CFBundleURLTypes")
            }
            info.setObject(options.bundleId, forKey: "CFBundleIdentifier" as NSCopying)
            // TODO: add name and version
            try info.write(to: bundle.appendingPathComponent("Info.plist"))
			
			
			var pw = ""
			if let pww = options.certificate?.password {
				pw = pww
			}
			print(pw)
			print(getDocumentsDirectory().path + "/Certificates/" + (options.certificate?.uuid ?? "") + "/" + (options.certificate?.provisionPath)!)
			print(getDocumentsDirectory().path + "/Certificates/" + (options.certificate?.uuid ?? "") + "/" + (options.certificate?.p12Path)!)
            if zsign(bundle.path,
					 getDocumentsDirectory().path + "/Certificates/" + (options.certificate?.uuid ?? "") + "/" + (options.certificate?.provisionPath)!,
					 getDocumentsDirectory().path + "/Certificates/" + (options.certificate?.uuid ?? "") + "/" + (options.certificate?.p12Path)!,
					 pw) != 0
			{
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
				let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

                let newSignedApp = SignedApps(context: context)
                newSignedApp.appPath = contents.first!.lastPathComponent
                newSignedApp.bundleidentifier = options.bundleId
                newSignedApp.dateAdded = Date()
                
                if let iconsDict = info["CFBundleIcons"] as? [String: Any],
                   let primaryIconsDict = iconsDict["CFBundlePrimaryIcon"] as? [String: Any],
                   let iconFiles = primaryIconsDict["CFBundleIconFiles"] as? [String],
                   let iconFileName = iconFiles.first {
                    newSignedApp.iconURL = iconFileName
                }
                
                newSignedApp.name = options.name
                // TODO: team name, ttl
                
                newSignedApp.version = options.version
                
                newSignedApp.uuid = signedUUID
                
                do {
                    try context.save()
                } catch {
                    print("Fail: \(error)")
                }
                completion(true)
            }
        } catch {
            print("Fail: \(error)")
            DispatchQueue.main.async {
                completion(false)
            }
        }
    }
}
