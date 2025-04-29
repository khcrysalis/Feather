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
	#if IDEVICE
	let heartbeat = HeartbeatManager.shared
	#endif
	let storage = Storage.shared

	var body: some Scene {
		WindowGroup {
			VariedTabbarView()
				.environment(\.managedObjectContext, storage.context)
				.onOpenURL(perform: _handleURL)
		}
	}
	
	private func _handleURL(_ url: URL) {
		if url.pathExtension == "ipa" {
			if url.startAccessingSecurityScopedResource() {
				FR.handlePackageFile(url) { _ in }
			}
		}
	}
}

class AppDelegate: NSObject, UIApplicationDelegate {
	func application(
		_ application: UIApplication,
		didFinishLaunchingWithOptions launchOptions:
			[UIApplication.LaunchOptionsKey: Any]? = nil
	) -> Bool {
		_createSourcesDirectory()
		return true
	}

	private func _createSourcesDirectory() {
		let fileManager = FileManager.default

		let directories = ["Signed", "Unsigned", "Certificates", "Archives"].map {
			URL.documentsDirectory.appendingPathComponent($0)
		}
		
		for url in directories where !fileManager.fileExists(atPath: url.path) {
			try? fileManager.createDirectory(
				at: url,
				withIntermediateDirectories: true,
				attributes: nil
			)
		}
	}
}
