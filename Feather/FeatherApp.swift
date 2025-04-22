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
			VariedTabbarView()
				.environment(\.managedObjectContext, storage.context)
				.onOpenURL(perform: _handleURL)
		}
	}
	
	#warning("this could be turned in its own static function, in an enum")
	private func _handleURL(_ url: URL) {
		if url.pathExtension == "ipa" {
			if url.startAccessingSecurityScopedResource() {
				Task.detached {
					defer {
						url.stopAccessingSecurityScopedResource()
					}
					
					let handler = AppFileHandler(file: url)
					
					do {
						try await handler.copy()
						try await handler.extract()
						try await handler.move()
						try await handler.addToDatabase()
					} catch {
						try await handler.clean()
						print(error)
					}
				}
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

		let directories = ["Signed", "Unsigned", "Certificates"].map {
			FileManager.default.documentsDirectory.appendingPathComponent($0)
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
