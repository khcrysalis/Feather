//
//  FeatherApp.swift
//  Feather
//
//  Created by samara on 10.04.2025.
//

import SwiftUI
import Nuke
import IDeviceSwift

@main
struct FeatherApp: App {
	@UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
	
	let heartbeat = HeartbeatManager.shared
	
	@StateObject var downloadManager = DownloadManager.shared
	let storage = Storage.shared
	
	@State private var certImportAlert: ImportAlert?
	
	private struct ImportAlert: Identifiable {
		let id = UUID()
		let title: String
		let message: String
	}
	
	var body: some Scene {
		WindowGroup {
			VStack {
				DownloadHeaderView(downloadManager: downloadManager)
					.transition(.move(edge: .top).combined(with: .opacity))
				VariedTabbarView()
					.environment(\.managedObjectContext, storage.context)
					.onOpenURL(perform: _handleURL)
					.transition(.move(edge: .top).combined(with: .opacity))
					.alert(item: $certImportAlert) { alert in
						Alert(
							title: Text(alert.title),
							message: Text(alert.message),
							dismissButton: .default(Text("OK"))
						)
					}
			}
			.animation(.smooth, value: downloadManager.manualDownloads.description)
			.onReceive(NotificationCenter.default.publisher(for: .heartbeatInvalidHost)) { _ in
				DispatchQueue.main.async {
					UIAlertController.showAlertWithOk(
						title: "InvalidHostID",
						message: .localized("Your pairing file is invalid and is incompatible with your device, please import a valid pairing file.")
					)
				}
			}
			// dear god help me
			.onAppear {
				if let style = UIUserInterfaceStyle(rawValue: UserDefaults.standard.integer(forKey: "Feather.userInterfaceStyle")) {
					UIApplication.topViewController()?.view.window?.overrideUserInterfaceStyle = style
				}
				
				UIApplication.topViewController()?.view.window?.tintColor = UIColor(Color(hex: UserDefaults.standard.string(forKey: "Feather.userTintColor") ?? "#B496DC"))
			}
		}
	}
	
	private func _handleURL(_ url: URL) {
		if url.scheme == "feather" {
			// IMPORT CERTIFICATE VIA URL SCHEME: feather://import-certificate?p12=<base64>&mobileprovision=<base64>&password=<base64>
			if url.host == "import-certificate" {
				// Parse query parameters
				guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return }
				let queryItems = components.queryItems ?? []
				func item(_ name: String) -> String? {
					return queryItems.first(where: { $0.name == name })?.value?.removingPercentEncoding
				}

				guard
					let p12Base64Raw = item("p12"),
					let provisionBase64Raw = item("mobileprovision"),
					let passwordBase64Raw = item("password")
				else {
					certImportAlert = ImportAlert(title: "Error", message: "Invalid certificate import URL. Missing parameters.")
					return
				}

				// Restore + that might have been replaced by space after url decoding
				let p12Base64 = p12Base64Raw.replacingOccurrences(of: " ", with: "+")
				let provisionBase64 = provisionBase64Raw.replacingOccurrences(of: " ", with: "+")
				let passwordBase64 = passwordBase64Raw.replacingOccurrences(of: " ", with: "+")

				guard
					let p12Data = Data(base64Encoded: p12Base64),
					let provisionData = Data(base64Encoded: provisionBase64),
					let passwordData = Data(base64Encoded: passwordBase64),
					let password = String(data: passwordData, encoding: .utf8)
				else {
					certImportAlert = ImportAlert(title: "Error", message: "Unable to decode certificate data.")
					return
				}

				// Write temp files
				let tmpDir = FileManager.default.temporaryDirectory
				let p12URL = tmpDir.appendingPathComponent(UUID().uuidString + ".p12")
				let provisionURL = tmpDir.appendingPathComponent(UUID().uuidString + ".mobileprovision")

				try? p12Data.write(to: p12URL)
				try? provisionData.write(to: provisionURL)

				FR.handleCertificateFiles(
					p12URL: p12URL,
					provisionURL: provisionURL,
					p12Password: password,
					certificateName: ""
				) { error in
					if let error = error {
						certImportAlert = ImportAlert(title: "Error", message: error.localizedDescription)
					} else {
						certImportAlert = ImportAlert(title: "Success", message: "Certificate imported successfully.")
					}
				}
				return
			}
			
			if let fullPath = url.validatedScheme(after: "/source/") {
				FR.handleSource(fullPath) { }
			}
			
			if
				let fullPath = url.validatedScheme(after: "/install/"),
				let downloadURL = URL(string: fullPath)
			{
				_ = DownloadManager.shared.startDownload(from: downloadURL)
			}
		} else {
			if url.pathExtension == "ipa" || url.pathExtension == "tipa" {
				if FileManager.default.isFileFromFileProvider(at: url) {
					guard url.startAccessingSecurityScopedResource() else { return }
					FR.handlePackageFile(url) { _ in }
				} else {
					FR.handlePackageFile(url) { _ in }
				}
				
				return
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
		_createDocumentsDirectories()
		ResetView.clearWorkCache()
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
	
	private func _createDocumentsDirectories() {
		let fileManager = FileManager.default

		let directories: [URL] = [
			fileManager.archives,
			fileManager.certificates,
			fileManager.signed,
			fileManager.unsigned
		]
		
		for url in directories {
			try? fileManager.createDirectoryIfNeeded(at: url)
		}
	}
}
