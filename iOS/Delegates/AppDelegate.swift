//
//  AppDelegate.swift
//  feather
//
//  Created by samara on 5/17/24.
//

import UIKit
import Nuke
import CoreData
import UIOnboarding

var downloadTaskManager = DownloadTaskManager.shared
class AppDelegate: UIResponder, UIApplicationDelegate, UIOnboardingViewControllerDelegate {

	static let isSideloaded = Bundle.main.bundleIdentifier != "kh.crysalis.feather"
	var window: UIWindow?

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		UserDefaults.standard.set(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String, forKey: "currentVersion")
		addDefaultRepos()
		imagePipline()

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
		
		let generatedString = AppDelegate.generateRandomString()
		if Preferences.pPQCheckString.isEmpty {
			Preferences.pPQCheckString = generatedString
		}
    
    if Preferences.isOnboardingActive {
      let onboardingController: UIOnboardingViewController = .init(withConfiguration: .setUp())
      onboardingController.delegate = self
      self.window?.rootViewController?.present(onboardingController, animated: false)
    }
		
		return true
	}
  
  func didFinishOnboarding(onboardingViewController: UIOnboardingViewController) {
    Preferences.isOnboardingActive = false // stop showing onboarding from now on.
    onboardingViewController.modalTransitionStyle = .crossDissolve
    onboardingViewController.dismiss(animated: true, completion: nil)
  }
	
	fileprivate func addDefaultRepos() {
		if !Preferences.defaultRepos {
			CoreDataManager.shared.saveSource(
				name: "Feather Repostory",
				id: "kh.crysalis.feather-repo",
				iconURL: URL(string: "https://github.com/khcrysalis/feather/blob/main/feather/Resources/Assets.xcassets/AppIcon.appiconset/feather.png?raw=true"),
				url: "https://github.com/khcrysalis/Feather/raw/main/app-repo.json")
			{_ in
				Debug.shared.log(message: "Added default repos!")
				Preferences.defaultRepos = true
			}
		}
	}
	
	fileprivate static func generateRandomString(length: Int = 8) -> String {
		let characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
		return String((0..<length).map { _ in characters.randomElement()! })
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

extension UIOnboardingViewConfiguration {
  static func setUp() -> Self {
    let welcomeToLine = NSMutableAttributedString(string: "Welcome to")
    let featherLine = NSMutableAttributedString(string: "Feather", attributes: [
      .foregroundColor: Preferences.appTintColor.uiColor
    ])
    
    let onboardingFeatures: [UIOnboardingFeature] = [
      .init(
        icon: UIImage(systemName: "square.and.arrow.down")!,
        iconTint: Preferences.appTintColor.uiColor,
        title: "Install Apps Directly on Your Device",
        description: "Sideload apps without a computer; manage apps directly on your device."
      ),
      .init(
        icon: UIImage(systemName: "wrench.and.screwdriver")!,
        iconTint: Preferences.appTintColor.uiColor,
        title: "Customize Apps with Tweaks",
        description: "Inject tweaks and modifications into your apps."
      ),
      .init(
        icon: UIImage(systemName: "tray.full")!,
        iconTint: Preferences.appTintColor.uiColor,
        title: "Access AltStore Repos",
        description: "Browse and install apps from your AltStore repositories, all from within the app."
      )
    ]
    return .init(
      appIcon: .init(named: "AppIcon")!,
      firstTitleLine: welcomeToLine,
      secondTitleLine: featherLine,
      features: onboardingFeatures,
      buttonConfiguration: .init(title: "Continue", backgroundColor: Preferences.appTintColor.uiColor)
    )
  }
}
