import CoreData
import Foundation

@objc class SourceRefreshOperation: Operation, @unchecked Sendable {
    private let queue = DispatchQueue(label: "kh.crysalis.feather.sourcerefresh", qos: .userInitiated)
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
            var allSourceData: [(data: SourcesData, url: URL)] = []

            if self.isDebugMode {
                dispatchGroup.enter()
                self.createMockSource { mockSource in
                    if let mockSource {
                        allSourceData.append((data: mockSource, url: URL(string: "https://example.com")!))
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
                            Debug.shared.log(message: "Received source data from URL: \(url)", type: .info)
                            if case let .success(sourceData) = SourceGET().parse(data: data) {
                                allSourceData.append((data: sourceData, url: url))
                            }
                        case let .failure(error):
							Debug.shared.log(message: "Source refresh error: \(error)", type: .info)
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

    private func checkForUpdates(with sourceData: [(data: SourcesData, url: URL)]) {
        let coreDataQueue = DispatchQueue(label: "kh.crysalis.feather.coredata", qos: .userInitiated)
        
        coreDataQueue.sync {
            let signedApps = CoreDataManager.shared.getDatedSignedApps()
            Debug.shared.log(message: "Found \(signedApps.count) signed apps to check", type: .info)
            Debug.shared.log(message: "Checking against \(sourceData.count) sources", type: .info)
            var updatedApps: [(name: String, oldVersion: String, newVersion: String)] = []

            for signedApp in signedApps {
                guard let bundleId = signedApp.bundleidentifier,
                      let currentVersion = signedApp.version else { continue }
                
                Debug.shared.log(message: "Checking app: \(bundleId) (current version: \(currentVersion))", type: .info)

                for source in sourceData {
                    if let availableApp = source.data.apps.first(where: { $0.bundleIdentifier == bundleId }) {
                        Debug.shared.log(message: "Found matching app in source: \(availableApp.bundleIdentifier)", type: .info)
                        
                        let versions = availableApp.versions ?? []
                        let latestVersion = versions.map { $0.version }.sorted { compareVersions($0, $1) > 0 }.first ?? availableApp.version
                        
                        if let latestVersion {
                            Debug.shared.log(message: "Comparing versions - Current: \(currentVersion) vs Latest: \(latestVersion)", type: .info)
                            let comparison = compareVersions(latestVersion, currentVersion)
                            Debug.shared.log(message: "Version comparison result: \(comparison)", type: .info)
                            
                            if comparison > 0 {
                                Debug.shared.log(message: "Update available - \(bundleId) can be updated from \(currentVersion) to \(latestVersion)", type: .info)
                                updatedApps.append((name: signedApp.name ?? bundleId,
                                                  oldVersion: currentVersion,
                                                  newVersion: latestVersion))

                                Debug.shared.log(message: "Setting source URL: \(source.url.absoluteString)", type: .info)
                                signedApp.originalSourceURL = source.url
                                CoreDataManager.shared.saveContext()
                                CoreDataManager.shared.setUpdateAvailable(for: signedApp, newVersion: latestVersion)
                                Debug.shared.log(message: "CoreData updated - Update marked as available for \(bundleId) from source \(source.url.absoluteString)", type: .info)
                                Debug.shared.log(message: "Verifying update data - URL: \(signedApp.originalSourceURL?.absoluteString ?? "nil"), Version: \(signedApp.updateVersion ?? "nil")", type: .info)

                                DispatchQueue.main.async {
                                    NotificationCenter.default.post(name: Notification.Name("lfetch"), object: nil)
                                }
                                return
                            }
                        }
                    }
                }
            }
        }
    }
	
	private func cleanVersion(_ version: String) -> String {
		// find first occurrence of version pattern X.Y.Z
		let pattern = "\\d+(\\.\\d+)+"
		if let range = version.range(of: pattern, options: .regularExpression) {
			return String(version[range])
		}
		return version
	}

    private func compareVersions(_ v1: String, _ v2: String) -> Int {
		let cleanV1 = cleanVersion(v1)
		let cleanV2 = cleanVersion(v2)
		
		let v1Components = cleanV1.split(separator: ".").compactMap { Int($0) }
		let v2Components = cleanV2.split(separator: ".").compactMap { Int($0) }

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
                Debug.shared.log(message: "Debug mode: Missing bundle identifier", type: .info)
                completion(nil)
                return
            }
            guard let currentVersion = firstApp.version else {
                Debug.shared.log(message: "Debug mode: Missing version", type: .error)
                completion(nil)
                return
            }
            
            // Get the actual source URL 
            let sources = CoreDataManager.shared.getAZSources()
            guard let source = sources.first,
                  let sourceURL = source.sourceURL else {
                Debug.shared.log(message: "Debug mode: No sources found", type: .error)
                completion(nil)
                return
            }

            Debug.shared.log(message: "Debug mode: Creating mock update for \(bundleId) (current: \(currentVersion))", type: .info)
            
            let jsonString = """
            {
                "name": "Mock Source",
                "identifier": "mock.source",
                "sourceURL": "\(sourceURL.absoluteString)",
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
                Debug.shared.log(message: "Debug mode: Failed to create mock source", type: .info)
                completion(nil)
            }
        } else {
            Debug.shared.log(message: "Debug mode: Could not find suitable app for mocking", type: .info)
            completion(nil)
        }
    }
} 
