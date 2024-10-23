//
//  ResetDataClass.swift
//  feather
//
//  Created by samara on 22.10.2024.
//

import Foundation
import Nuke

class ResetDataClass {
	static let shared = ResetDataClass()
	
	init() {}
	deinit {}
	
	public func clearNetworkCache() {
		URLCache.shared.removeAllCachedResponses()
		HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
		
		if let dataCache = ImagePipeline.shared.configuration.dataCache as? DataCache {
			dataCache.removeAll()
		}
		
		if let imageCache = ImagePipeline.shared.configuration.imageCache as? Nuke.ImageCache {
			imageCache.removeAll()
		}
	}
	
	public func deleteSignedApps() {
		CoreDataManager.shared.clearSignedApps()
		self.deleteDirectory(named: "Apps", additionalComponents: ["Signed"])
	}
	
	public func deleteDownloadedApps() {
		CoreDataManager.shared.clearDownloadedApps()
		self.deleteDirectory(named: "Apps", additionalComponents: ["Unsigned"])
	}
	
	public func resetCertificates(resetAll: Bool) {
		if !resetAll { Preferences.selectedCert = 0 }
		CoreDataManager.shared.clearCertificate()
		self.deleteDirectory(named: "Certificates")
	}
	
	public func resetSources(resetAll: Bool) {
		if !resetAll { Preferences.defaultRepos = false }
		CoreDataManager.shared.clearSources()
	}
	
	private func resetAllUserDefaults() {
		if let bundleID = Bundle.main.bundleIdentifier {
			UserDefaults.standard.removePersistentDomain(forName: bundleID)
		}
	}
	
	public func resetAll() {
		self.deleteSignedApps()
		self.deleteDownloadedApps()
		self.resetCertificates(resetAll: true)
		self.resetSources(resetAll: true)
		self.resetAllUserDefaults()
		self.clearNetworkCache()
	}
	
	private func deleteDirectory(named directoryName: String, additionalComponents: [String]? = nil) {
		var directoryURL = getDocumentsDirectory().appendingPathComponent(directoryName)
		
		if let components = additionalComponents {
			for component in components {
				directoryURL.appendPathComponent(component)
			}
		}
		
		let fileManager = FileManager.default
		do {
			try fileManager.removeItem(at: directoryURL)
		} catch {
			Debug.shared.log(message: "Couldn't delete this, but thats ok!: \(error)", type: .debug)
		}
	}
}
