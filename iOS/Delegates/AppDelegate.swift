//
//  AppDelegate.swift
//  feather
//
//  Created by samara on 5/17/24.
//

import UIKit
import Nuke
import CoreData

var downloadTaskManager = DownloadTaskManager.shared
class AppDelegate: UIResponder, UIApplicationDelegate {

	static let isSideloaded = Bundle.main.bundleIdentifier != "kh.crysalis.feather"
	var window: UIWindow?
	#if !targetEnvironment(simulator)
	var savedStdout: Int32 = -1
	var savedStderr: Int32 = -1
	var outPipe: Pipe?
	var fileHandle: FileHandle?
	var semaphore: DispatchSemaphore?
	#endif

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		UserDefaults.standard.set(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String, forKey: "currentVersion")
		
		imagePipline()
		#if !targetEnvironment(simulator)
		startPiping()
		#endif
		let tabBarController = TabbarController()
		window = UIWindow(frame: UIScreen.main.bounds)
		window?.rootViewController = tabBarController
		
		DispatchQueue.main.async {
			self.window!.tintColor = Preferences.appTintColor.uiColor
			self.window!.overrideUserInterfaceStyle = UIUserInterfaceStyle(rawValue: Preferences.preferredInterfaceStyle) ?? .unspecified
		}
		
		window?.makeKeyAndVisible()
		createSourcesDirectory()
        let fileManager = FileManager.default
        let tmpDirectory = NSHomeDirectory() + "/tmp"
        
        if let files = try? fileManager.contentsOfDirectory(atPath: tmpDirectory) {
            for file in files {
                try? fileManager.removeItem(atPath: tmpDirectory + "/" + file)
            }
        }
		return true
	}
	
	func createSourcesDirectory() {
		let fileManager = FileManager.default
		if let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
			let sourcesURL = documentsURL.appendingPathComponent("Apps")
			let certsURL = documentsURL.appendingPathComponent("Certificates")
			
			if !fileManager.fileExists(atPath: sourcesURL.path) {
				do { try! fileManager.createDirectory(at: sourcesURL, withIntermediateDirectories: true, attributes: nil) }
			}
			if !fileManager.fileExists(atPath: certsURL.path) {
				do { try! fileManager.createDirectory(at: certsURL, withIntermediateDirectories: true, attributes: nil) }
			}
		}
	}
	
	func imagePipline() {
		DataLoader.sharedUrlCache.diskCapacity = 0
		let pipeline = ImagePipeline {
			let dataLoader: DataLoader = {
				let config = URLSessionConfiguration.default
				config.urlCache = nil
				return DataLoader(configuration: config)
			}()
			let dataCache = try? DataCache(name: "com.ssalggnikool.pointercrate.datacache") // disk cache
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
}
#if !targetEnvironment(simulator)
extension AppDelegate {
	func startPiping() {
		outPipe = Pipe()
		semaphore = DispatchSemaphore(value: 0)
		
		
		let fileManager = FileManager.default
		let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
		let logFileURL = documentsDirectory.appendingPathComponent("stdout.log")
		
		if fileManager.fileExists(atPath: logFileURL.path) {
			do { try! fileManager.removeItem(at: logFileURL) }
		}
		
		FileManager.default.createFile(atPath: logFileURL.path, contents: nil, attributes: nil)
		fileHandle = try? FileHandle(forWritingTo: logFileURL)
		savedStdout = dup(STDOUT_FILENO)
		savedStderr = dup(STDERR_FILENO)
		dup2(outPipe!.fileHandleForWriting.fileDescriptor, STDOUT_FILENO)
		dup2(outPipe!.fileHandleForWriting.fileDescriptor, STDERR_FILENO)
		
		outPipe!.fileHandleForReading.readabilityHandler = { [weak self] fileHandle in
			let data = fileHandle.availableData
			if data.isEmpty {
				fileHandle.readabilityHandler = nil
				self?.semaphore?.signal()
			} else {
				_ = String(data: data, encoding: .utf8) ?? ""
				self?.fileHandle?.write(data)
			}
		}
		
		setvbuf(stdout, nil, _IONBF, 0)
		setvbuf(stderr, nil, _IONBF, 0)
	}
	func applicationWillTerminate(_ application: UIApplication) {
		dup2(savedStdout, STDOUT_FILENO)
		dup2(savedStderr, STDERR_FILENO)
		close(savedStdout)
		close(savedStderr)
		
		fileHandle?.closeFile()
		outPipe?.fileHandleForWriting.closeFile()
		semaphore?.wait()
	}
}
#endif
