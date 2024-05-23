//
//  AppDelegate.swift
//  feather
//
//  Created by samara on 5/17/24.
//

import UIKit

class AppDelegate: UIResponder, UIApplicationDelegate {

	static let isSideloaded = Bundle.main.bundleIdentifier != "kh.crysalis.feather"
	var window: UIWindow?

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		UserDefaults.standard.set(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String, forKey: "currentVersion")

		let tabBarController = TabbarController()
		window = UIWindow(frame: UIScreen.main.bounds)
		window?.rootViewController = tabBarController
		
		DispatchQueue.main.async {
			self.window!.tintColor = Preferences.appTintColor.uiColor
			self.window!.overrideUserInterfaceStyle = UIUserInterfaceStyle(rawValue: Preferences.preferredInterfaceStyle) ?? .unspecified
		}
		
		window?.makeKeyAndVisible()
		createSourcesDirectory()
        runHTTPSServer()
		return true
	}
	
	func createSourcesDirectory() {
		let fileManager = FileManager.default
		if let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
			let sourcesURL = documentsURL.appendingPathComponent("Sources")
			
			if !fileManager.fileExists(atPath: sourcesURL.path) {
				do { try! fileManager.createDirectory(at: sourcesURL, withIntermediateDirectories: true, attributes: nil) }
			}
		}
	}
}

