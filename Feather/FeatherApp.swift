//
//  FeatherApp.swift
//  Feather
//
//  Created by samara on 10.04.2025.
//

import SwiftUI
import Nuke

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
	
	#warning("we need to solve for ipa handling, possibly with a scene delegate?")
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
		didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
	) -> Bool {
		_createPipeline()
		_createSourcesDirectory()
		return true
	}
	
	private func _createPipeline() {
		DataLoader.sharedUrlCache.diskCapacity = 0
		
		let pipeline = ImagePipeline {
			let dataLoader: DataLoader = {
				let config = URLSessionConfiguration.default
				config.urlCache = nil
				return DataLoader(configuration: config)
			}()
			let dataCache = try? DataCache(name: "thewonderofyou.Feather.datacache") // disk cache
			let imageCache = Nuke.ImageCache() // memory cache
			dataCache?.sizeLimit = 500 * 1024 * 1024
			imageCache.costLimit = 100 * 1024 * 1024
			$0.dataCache = dataCache
			$0.imageCache = imageCache
			$0.dataLoader = dataLoader
			$0.dataCachePolicy = .automatic
			$0.isStoringPreviewsInMemoryCache = false
		}
		
		ImagePipeline.shared = pipeline
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
