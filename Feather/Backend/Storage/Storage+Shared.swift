//
//  Storage+Shared.swift
//  Feather
//
//  Created by samara on 17.04.2025.
//

import CoreData

// MARK: - Class extension: Apps (Shared)
extension Storage {
	func extractBundleInfo<T: BundleInfoAssignableData>(
		for app: inout T,
		using url: URL
	) {
		guard let appUrl = FileManager.default.getPath(in: url, for: "app") else {
			return
		}
		
		let bundle = Bundle(url: appUrl)
		app.identifier = bundle?.bundleIdentifier
		app.name = bundle?.name
		app.icon = bundle?.iconFileName
		app.version = bundle?.version
	}
	
	func getUuidDirectory(for app: AppInfoPresentable) -> URL? {
		guard let uuid = app.uuid else { return nil }
		return app.isSigned
		? FileManager.default.signed(uuid)
		: FileManager.default.unsigned(uuid)
	}
	
	func getAppDirectory(for app: AppInfoPresentable) -> URL? {
		guard let url = getUuidDirectory(for: app) else { return nil }
		return FileManager.default.getPath(in: url, for: "app")
	}
	
	func deleteApp(for app: AppInfoPresentable) {
		do {
			if let url = getUuidDirectory(for: app) {
				try FileManager.default.removeItem(at: url)
			}
			if let object = app as? NSManagedObject {
				context.delete(object)
			}
			saveContext()
		} catch {
			print(error)
		}
	}
}

// MARK: - Helpers
struct AnyApp: Identifiable {
	let base: AppInfoPresentable
	
	var id: String {
		base.uuid ?? UUID().uuidString
	}
}

protocol AppInfoPresentable {
	var name: String? { get }
	var version: String? { get }
	var identifier: String? { get }
	var date: Date? { get }
	var icon: String? { get }
	var uuid: String? { get }
	var isSigned: Bool { get }
}

protocol BundleInfoAssignableData {
	var identifier: String? { get set }
	var name: String? { get set }
	var icon: String? { get set }
	var version: String? { get set }
}

extension Signed: AppInfoPresentable {
	var isSigned: Bool { true }
}

extension Imported: AppInfoPresentable {
	var isSigned: Bool { false }
}

extension Imported: BundleInfoAssignableData {}
extension Signed: BundleInfoAssignableData {}
