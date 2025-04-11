//
//  FeatherApp.swift
//  Feather
//
//  Created by samara on 10.04.2025.
//

import SwiftUI

@main
struct FeatherApp: App {
	@UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
	
	let storage = Storage.shared

    var body: some Scene {
        WindowGroup {
			if #available(iOS 18, *) {
				ExtendedTabbarView()
					.environment(\.managedObjectContext, storage.context)
			} else {
				TabbarView()
					.environment(\.managedObjectContext, storage.context)
			}
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
		_createSourcesDirectory()
		return true
	}
	
	private func _createSourcesDirectory() {
		let fileManager = FileManager.default
		
		let directories = ["Apps", "Certificates"].map {
			FileManager.default.documentsDirectory.appendingPathComponent($0)
		}
		
		for url in directories where !fileManager.fileExists(atPath: url.path) {
			try? fileManager.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
		}
	}
}
