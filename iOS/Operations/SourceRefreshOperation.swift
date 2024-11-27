import CoreData
import Foundation
import UserNotifications

@objc class SourceRefreshOperation: Operation, @unchecked Sendable {
    private let queue = DispatchQueue(label: "kh.crysalis.feather.sourcerefresh", qos: .background)
    private let isDebugMode: Bool = {
        var isDebug = false
        assert({
            isDebug = true
            return true
        }())
        return isDebug
    }()

    override func main() {
        guard !isCancelled else { return }

        Debug.shared.log(message: "SourceRefreshOperation running in debug mode: \(isDebugMode)", type: .info)

        let semaphore = DispatchSemaphore(value: 0)

        queue.async {
            Debug.shared.log(message: "Starting source refresh", type: .info)

            let dispatchGroup = DispatchGroup()
            var allSourceData: [SourcesData] = []

            if self.isDebugMode {
                dispatchGroup.enter()
                self.createMockSource { mockSource in
                    if let mockSource {
                        allSourceData.append(mockSource)
                    }
                    dispatchGroup.leave()
                }
            } else {
                let sources = CoreDataManager.shared.getAZSources()
                for source in sources {
                    guard let url = source.sourceURL else { continue }

                    dispatchGroup.enter()
                    SourceGET().downloadURL(from: url) { result in
                        switch result {
                        case let .success((data, _)):
                            if case let .success(sourceData) = SourceGET().parse(data: data) {
                                allSourceData.append(sourceData)
                            }
                        case let .failure(error):
                            Debug.shared.log(message: "Source refresh error: \(error)", type: .error)
                        }
                        dispatchGroup.leave()
                    }
                }
            }

            dispatchGroup.notify(queue: self.queue) {
                self.checkForUpdates(with: allSourceData)
                semaphore.signal()
            }
        }

        _ = semaphore.wait(timeout: .now() + 30)
    }

    private func checkForUpdates(with sourceData: [SourcesData]) {
        let signedApps = CoreDataManager.shared.getDatedSignedApps()
        var updatesFound = false
        var updatedApps: [(name: String, oldVersion: String, newVersion: String)] = []

        for signedApp in signedApps {
            guard let bundleId = signedApp.bundleidentifier,
                  let currentVersion = signedApp.version,
                  let originalSourceURL = signedApp.originalSourceURL else { continue }

            for source in sourceData {
                if let availableApp = source.apps.first(where: { $0.bundleIdentifier == bundleId }),
                   let latestVersion = availableApp.version,
                   (!self.isDebugMode && source.sourceURL!.absoluteString == originalSourceURL.absoluteString) || self.isDebugMode,
                   compareVersions(latestVersion, currentVersion) > 0
                {
                    updatesFound = true
                    updatedApps.append((name: signedApp.name ?? bundleId,
                                      oldVersion: currentVersion,
                                      newVersion: latestVersion))

                    CoreDataManager.shared.setUpdateAvailable(for: signedApp, newVersion: latestVersion)

                    Debug.shared.log(message: "Update found for signed app:", type: .info)
                    Debug.shared.log(message: "Signed app object: \(signedApp)", type: .info)
                    Debug.shared.log(message: "Source object: \(source)", type: .info)
                    Debug.shared.log(message: "Available update app object: \(availableApp)", type: .info)

                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: Notification.Name("lfetch"), object: nil)
                    }
                }
            }
        }

        if updatesFound {
            sendUpdateNotification(for: updatedApps)
        } else {
            Debug.shared.log(message: "No updates available for signed apps", type: .info)
        }

        Debug.shared.log(message: "Source refresh completed", type: .info)
    }

    private func sendUpdateNotification(for apps: [(name: String, oldVersion: String, newVersion: String)]) {
        let content = UNMutableNotificationContent()
        content.title = apps.count == 1 ? "Update Available" : "Updates Available"

        if apps.count == 1 {
            let app = apps[0]
            content.body = "\(app.name) can be updated from \(app.oldVersion) to \(app.newVersion)"
            Debug.shared.log(message: "Sending notification for 1 update", type: .info)
        } else {
            content.body = "\(apps.count) app\(apps.count == 1 ? "" : "s") \(apps.count == 1 ? "has" : "have") \(apps.count == 1 ? "an update" : "updates") available"
            Debug.shared.log(message: "Sending notification for \(apps.count) updates", type: .info)
        }

        content.sound = .default
        let identifier = "feather.updates.\(UUID().uuidString)"

        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: nil
        )

        Debug.shared.log(message: "Attempting to send notification with id: \(identifier)", type: .info)

        UNUserNotificationCenter.current().add(request) { error in
            if let error {
                Debug.shared.log(message: "Error sending notification: \(error)", type: .error)
            } else {
                Debug.shared.log(message: "Successfully sent update notification", type: .info)
            }
        }
    }

    private func compareVersions(_ v1: String, _ v2: String) -> Int {
        let v1Components = v1.split(separator: ".").compactMap { Int($0) }
        let v2Components = v2.split(separator: ".").compactMap { Int($0) }

        for i in 0 ..< max(v1Components.count, v2Components.count) {
            let v1Component = i < v1Components.count ? v1Components[i] : 0
            let v2Component = i < v2Components.count ? v2Components[i] : 0

            if v1Component > v2Component {
                return 1
            } else if v1Component < v2Component {
                return -1
            }
        }
        return 0
    }

    func createMockSource(completion: @escaping (SourcesData?) -> Void) {
        let signedApps = CoreDataManager.shared.getDatedSignedApps()
        Debug.shared.log(message: "Debug mode: Found \(signedApps.count) signed app\(signedApps.count == 1 ? "" : "s")", type: .info)

        if let firstApp = signedApps.first {
            Debug.shared.log(message: "Debug mode: Checking app data:", type: .info)
            Debug.shared.log(message: "Bundle ID: \(firstApp.bundleidentifier ?? "missing")", type: .info)
            Debug.shared.log(message: "Version: \(firstApp.version ?? "missing")", type: .info)
            Debug.shared.log(message: "Source URL: \(firstApp.originalSourceURL?.absoluteString ?? "missing")", type: .info)
            
            guard let bundleId = firstApp.bundleidentifier else {
                Debug.shared.log(message: "Debug mode: Missing bundle identifier", type: .error)
                completion(nil)
                return
            }
            guard let currentVersion = firstApp.version else {
                Debug.shared.log(message: "Debug mode: Missing version", type: .error)
                completion(nil)
                return
            }
            guard let originalSourceURL = firstApp.originalSourceURL else {
                Debug.shared.log(message: "Debug mode: Missing source URL", type: .error)
                completion(nil)
                return
            }

            Debug.shared.log(message: "Debug mode: Creating mock update for \(bundleId) (current: \(currentVersion))", type: .info)
            
            let jsonString = """
            {
                "name": "Mock Source",
                "identifier": "mock.source",
                "sourceURL": "\(originalSourceURL.absoluteString)",
                "apps": [{
                    "name": "\(firstApp.name ?? "Mock App")",
                    "bundleIdentifier": "\(bundleId)",
                    "version": "999.0.0",
                    "subtitle": "Mock Update",
                    "localizedDescription": "Mock update for testing",
                    "versionDescription": "Debug mode test update",
                    "versions": [
                        {
                            "version": "999.0.0",
                            "date": "2024-11-1T18:35:10Z",
                            "size": 12375230,
                            "downloadURL": "https://github.com/khcrysalis/Feather/releases/download/v1.1.3/feather_v1.1.3.ipa"
                        }
                    ]
                }]
            }
            """

            if let jsonData = jsonString.data(using: .utf8),
               case let .success(mockSource) = SourceGET().parse(data: jsonData)
            {
                Debug.shared.log(message: "Debug mode: Successfully created mock source", type: .info)
                completion(mockSource)
            } else {
                Debug.shared.log(message: "Debug mode: Failed to create mock source", type: .error)
                completion(nil)
            }
        } else {
            Debug.shared.log(message: "Debug mode: Could not find suitable app for mocking", type: .error)
            completion(nil)
        }
    }
} 