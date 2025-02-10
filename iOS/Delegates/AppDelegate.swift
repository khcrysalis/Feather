//
//  AppDelegate.swift
//  feather
//
//  Created by samara on 5/17/24.
//  Copyright (c) 2024 Samara M (khcrysalis)
//

import BackgroundTasks
import CoreData
import Foundation
import Nuke
import SwiftUI
import UIKit
import UIOnboarding

var downloadTaskManager = DownloadTaskManager.shared
class AppDelegate: UIResponder, UIApplicationDelegate, UIOnboardingViewControllerDelegate {
    static let isSideloaded = Bundle.main.bundleIdentifier != "kh.crysalis.feather"
    var window: UIWindow?
    var loaderAlert = presentLoader()

    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let userDefaults = UserDefaults.standard

        userDefaults.set(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String, forKey: "currentVersion")

        if userDefaults.data(forKey: UserDefaults.signingDataKey) == nil {
            userDefaults.signingOptions = UserDefaults.defaultSigningData
        }

		createSourcesDirectory()
        addDefaultRepos()
		giveUserDefaultSSLCerts()
        imagePipline()
        setupLogFile()
        cleanTmp()

        window = UIWindow(frame: UIScreen.main.bounds)

        if Preferences.isOnboardingActive {
            let onboardingController: UIOnboardingViewController = .init(withConfiguration: .setUp())
            onboardingController.delegate = self
            window?.rootViewController = onboardingController
        } else {
            let tabBarController = UIHostingController(rootView: TabbarView())
            window?.rootViewController = tabBarController
        }

        DispatchQueue.main.async {
            self.window!.tintColor = Preferences.appTintColor.uiColor
            self.window!.overrideUserInterfaceStyle = UIUserInterfaceStyle(rawValue: Preferences.preferredInterfaceStyle) ?? .unspecified
        }

        window?.makeKeyAndVisible()

        let generatedString = AppDelegate.generateRandomString()
        if Preferences.pPQCheckString.isEmpty {
            Preferences.pPQCheckString = generatedString
        }

        Debug.shared.log(message: "Version: \(UIDevice.current.systemVersion)")
        Debug.shared.log(message: "Name: \(UIDevice.current.name)")
        Debug.shared.log(message: "Model: \(UIDevice.current.model)")
        Debug.shared.log(message: "Feather Version: \(logAppVersionInfo())\n")

		if Preferences.appUpdates {
			// Register background task
			BGTaskScheduler.shared.register(forTaskWithIdentifier: "kh.crysalis.feather.sourcerefresh", using: nil) { task in
				self.handleAppRefresh(task: task as! BGAppRefreshTask)
			}
			scheduleAppRefresh()
			
			let backgroundQueue = OperationQueue()
			backgroundQueue.qualityOfService = .background
			let operation = SourceRefreshOperation()
			backgroundQueue.addOperation(operation)
		}

        return true
    }

    func applicationWillEnterForeground(_: UIApplication) {
        let backgroundQueue = OperationQueue()
        backgroundQueue.qualityOfService = .background
        let operation = SourceRefreshOperation()
        backgroundQueue.addOperation(operation)
    }

    func scheduleAppRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: "kh.crysalis.feather.sourcerefresh")
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60)

        do {
            try BGTaskScheduler.shared.submit(request)
            Debug.shared.log(message: "Background refresh scheduled successfully", type: .info)
        } catch {
            Debug.shared.log(message: "Could not schedule app refresh: \(error.localizedDescription)", type: .info)
        }
    }

    func handleAppRefresh(task: BGAppRefreshTask) {
        scheduleAppRefresh()

        let backgroundQueue = OperationQueue()
        backgroundQueue.qualityOfService = .background
        let operation = SourceRefreshOperation()

        task.expirationHandler = {
            operation.cancel()
        }

        operation.completionBlock = {
            task.setTaskCompleted(success: !operation.isCancelled)
        }

        backgroundQueue.addOperation(operation)
    }

    func application(_: UIApplication, open url: URL, options _: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        if url.scheme == "feather" {
            // I know this is super hacky, honestly
            // I don't *exactly* care as it just works :shrug:
            if let config = url.absoluteString.range(of: "/source/") {
                let fullPath = String(url.absoluteString[config.upperBound...])

                if fullPath.starts(with: "https://") {
                    CoreDataManager.shared.getSourceData(urlString: fullPath) { error in
                        if let error {
                            Debug.shared.log(message: "SourcesViewController.sourcesAddButtonTapped: \(error)", type: .critical)
                        } else {
                            Debug.shared.log(message: "Successfully added!", type: .success)
                            NotificationCenter.default.post(name: Notification.Name("sfetch"), object: nil)
                        }
                    }
                } else {
                    Debug.shared.log(message: "Invalid or non-HTTPS URL", type: .error)
                }
            } else if let config = url.absoluteString.range(of: "/install/") {
                let fullPath = String(url.absoluteString[config.upperBound...])
                
                if fullPath.starts(with: "https://") {
                    guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                          let rootViewController = scene.windows.first?.rootViewController else {
                        return false
                    }
                    
                    DispatchQueue.main.async {
                        rootViewController.present(self.loaderAlert, animated: true)
                    }
                    
                    DispatchQueue.global(qos: .background).async {
                        do {
                            let tempDirectory = FileManager.default.temporaryDirectory
                            let uuid = UUID().uuidString
                            let destinationURL = tempDirectory.appendingPathComponent("\(uuid).ipa")
                            
                            // Download the file
                            if let data = try? Data(contentsOf: URL(string: fullPath)!) {
                                try data.write(to: destinationURL)
                                
                                let dl = AppDownload()
                                try handleIPAFile(destinationURL: destinationURL, uuid: uuid, dl: dl)
                                
                                DispatchQueue.main.async {
                                    self.loaderAlert.dismiss(animated: true) {
                                        let downloadedApps = CoreDataManager.shared.getDatedDownloadedApps()
                                        if let downloadedApp = downloadedApps.first(where: { $0.uuid == uuid }) {
                                            let signingDataWrapper = SigningDataWrapper(signingOptions: UserDefaults.standard.signingOptions)
                                            signingDataWrapper.signingOptions.installAfterSigned = true
                                            
                                            let libraryVC = LibraryViewController()
                                            let ap = SigningsViewController(
                                                signingDataWrapper: signingDataWrapper,
                                                application: downloadedApp,
                                                appsViewController: libraryVC
                                            )
                                            
                                            ap.signingCompletionHandler = { success in
                                                if success {
                                                    if let workspace = LSApplicationWorkspace.default() {
                                                        if let bundleId = downloadedApp.bundleidentifier {
                                                            workspace.openApplication(withBundleID: bundleId)
                                                        }
                                                    }
                                                    libraryVC.fetchSources()
                                                    libraryVC.tableView.reloadData()
                                                }
                                            }
                                            
                                            let navigationController = UINavigationController(rootViewController: ap)
                                            
											navigationController.shouldPresentFullScreen()
                                            
                                            rootViewController.present(navigationController, animated: true)
                                        }
                                    }
                                }
                            }
                        } catch {
                            DispatchQueue.main.async {
                                self.loaderAlert.dismiss(animated: true)
                                Debug.shared.log(message: "Failed to handle IPA file: \(error)", type: .error)
                            }
                        }
                    }
                } else {
                    Debug.shared.log(message: "Invalid or non-HTTPS URL", type: .error)
                }
            }

            return true
        }
        // bwah
        if url.pathExtension == "ipa" {
            guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let rootViewController = scene.windows.first?.rootViewController else {
                return false
            }

            DispatchQueue.main.async {
                rootViewController.present(self.loaderAlert, animated: true)
            }

            DispatchQueue.global(qos: .background).async {
                do {
                    let tempDirectory = FileManager.default.temporaryDirectory
                    let destinationURL = tempDirectory.appendingPathComponent(url.lastPathComponent)
                    try FileManager.default.copyItem(at: url, to: destinationURL)

                    let dl = AppDownload()
                    let uuid = UUID().uuidString

                    try handleIPAFile(destinationURL: destinationURL, uuid: uuid, dl: dl)

                    DispatchQueue.main.async {
                        self.loaderAlert.dismiss(animated: true)
                        Debug.shared.log(message: "Moved IPA file to: \(destinationURL)")
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.loaderAlert.dismiss(animated: true)
                        Debug.shared.log(message: "Failed to move IPA file: \(error)")
                    }
                }
            }

            return true
        }

        return false
    }

    func didFinishOnboarding(onboardingViewController _: UIOnboardingViewController) {
        Preferences.isOnboardingActive = false

        let tabBarController = UIHostingController(rootView: TabbarView())

        let transition = CATransition()
        transition.type = .fade
        transition.duration = 0.3

        window?.layer.add(transition, forKey: kCATransition)

        window?.rootViewController = tabBarController
    }

    fileprivate func addDefaultRepos() {
        if !Preferences.defaultRepos {
            CoreDataManager.shared.saveSource(
                name: "Feather Repository",
                id: "kh.crysalis.feather-repo",
                iconURL: URL(string: "https://github.com/khcrysalis/Feather/blob/main/iOS/Icons/Main/Mac%403x.png?raw=true"),
                url: "https://github.com/khcrysalis/Feather/raw/main/app-repo.json"
            ) { _ in
                Debug.shared.log(message: "Added default repos!")
                Preferences.defaultRepos = true
            }
        }
    }
	
	fileprivate func giveUserDefaultSSLCerts() {
		if !Preferences.gotSSLCerts {
			getCertificates()
			Preferences.gotSSLCerts = true
		}
	}

    fileprivate static func generateRandomString(length: Int = 8) -> String {
        let characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0 ..< length).map { _ in characters.randomElement()! })
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
            let dataCache = try? DataCache(name: "kh.crysalis.feather.datacache") // disk cache
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

    func setupLogFile() {
        let logFilePath = getDocumentsDirectory().appendingPathComponent("logs.txt")
        if FileManager.default.fileExists(atPath: logFilePath.path) {
            do {
                try FileManager.default.removeItem(at: logFilePath)
            } catch {
                Debug.shared.log(message: "Error removing existing logs.txt: \(error)", type: .error)
            }
        }

        do {
            try "".write(to: logFilePath, atomically: true, encoding: .utf8)
        } catch {
            Debug.shared.log(message: "Error removing existing logs.txt: \(error)", type: .error)
        }
    }

    func cleanTmp() {
        let fileManager = FileManager.default
        let tmpDirectory = NSHomeDirectory() + "/tmp"

        if let files = try? fileManager.contentsOfDirectory(atPath: tmpDirectory) {
            for file in files {
                try? fileManager.removeItem(atPath: tmpDirectory + "/" + file)
            }
        }
    }

    public func logAppVersionInfo() -> String {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
           let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        {
            return "App Version: \(version) (\(build))"
        }
        return ""
    }
}

extension UIOnboardingViewConfiguration {
    static func setUp() -> Self {
        let welcomeToLine = NSMutableAttributedString(string: String.localized("ONBOARDING_WELCOMETITLE_1"))
        let featherLine = NSMutableAttributedString(string: "Feather", attributes: [
            .foregroundColor: UIColor.tintColor,
        ])

        let featureStyle = UIOnboardingFeatureStyle(
            titleFontName: "",
            titleFontSize: 17,
            descriptionFontName: "",
            descriptionFontSize: 16,
            spacing: 0.8
        )

        let onboardingFeatures: [UIOnboardingFeature] = [
            .init(
                icon: UIImage(systemName: "arrow.down.app.fill")!,
                iconTint: .label,
                title: String.localized("ONBOARDING_CELL_1_TITLE"),
                description: String.localized("ONBOARDING_CELL_1_DESCRIPTION")
            ),
            .init(
                icon: UIImage(systemName: "sparkles.square.filled.on.square")!,
                iconTint: .tintColor,
                title: String.localized("ONBOARDING_CELL_2_TITLE"),
                description: String.localized("ONBOARDING_CELL_2_DESCRIPTION")
            ),
            .init(
                icon: UIImage(systemName: "sparkles")!,
                iconTint: .systemYellow,
                title: String.localized("ONBOARDING_CELL_3_TITLE"),
                description: String.localized("ONBOARDING_CELL_3_DESCRIPTION")
            ),
        ]

        let text = UIOnboardingTextViewConfiguration(
            text: String.localized("ONBOARDING_FOOTER"),
            linkTitle: String.localized("ONBOARDING_FOOTER_LINK"),
            link: "https://github.com/khcrysalis/feather?tab=readme-ov-file#features",
            tint: .tintColor
        )

        return .init(
            appIcon: .init(named: "AppIcon60x60")!,
            firstTitleLine: welcomeToLine,
            secondTitleLine: featherLine,
            features: onboardingFeatures,
            featureStyle: featureStyle,
            textViewConfiguration: text,
            buttonConfiguration: .init(title: String.localized("ONBOARDING_CONTINUE_BUTTON"), backgroundColor: .tintColor)
        )
    }
}
