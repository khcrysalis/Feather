//
//  CoreDataManager+DownloadedApps.swift
//  feather
//
//  Created by samara on 8/2/24.
//  Copyright (c) 2024 Samara M (khcrysalis)
//

import CoreData

extension CoreDataManager {
	
	/// Clear all dl from Core Data and delete files
	func clearDownloadedApps(
		context: NSManagedObjectContext? = nil) {
			let context = context ?? self.context
			clear(request: DownloadedApps.fetchRequest(), context: context)
	}
	
	/// Fetch all sources sorted alphabetically by name
	func getDatedDownloadedApps(
		context: NSManagedObjectContext? = nil) -> [DownloadedApps] {
			let request: NSFetchRequest<DownloadedApps> = DownloadedApps.fetchRequest()
			request.sortDescriptors = [NSSortDescriptor(key: "dateAdded", ascending: false)]
			return (try? (context ?? self.context).fetch(request)) ?? []
	}
	
	/// Add application to downloaded apps
	func addToDownloadedApps(
		context: NSManagedObjectContext? = nil,
		version: String,
		name: String,
		bundleidentifier: String,
		iconURL: String?,
		dateAdded: Date? = Date(),
		uuid: String,
		appPath: String?,
		sourceLocation: String? = "Imported",
		sourceURL: URL? = nil,
		completion: @escaping (Error?) -> Void) {
			let context = context ?? self.context
			let newApp = DownloadedApps(context: context)
			
			newApp.version = version
			newApp.name = name
			newApp.bundleidentifier = bundleidentifier
			newApp.iconURL = iconURL
			newApp.dateAdded = dateAdded
			newApp.uuid = uuid
			newApp.appPath = appPath
			newApp.oSU = sourceURL?.absoluteString ?? sourceLocation
			
			do {
				try context.save()
				NotificationCenter.default.post(name: Notification.Name("lfetch"), object: nil)
			} catch {
				Debug.shared.log(message: "Error saving data: \(error)", type: .error)
			}
	}
	
	/// Get application file path
	func getFilesForDownloadedApps(for app: DownloadedApps, getuuidonly: Bool = false) -> URL {
		guard let uuid = app.uuid, let appPath = app.appPath, let dir = app.directory else { return URL(string: "")!}
		
		let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
		var path = documentsDirectory
			.appendingPathComponent("Apps")
			.appendingPathComponent(dir)
			.appendingPathComponent(uuid)
		
		if !getuuidonly { path = path.appendingPathComponent(appPath) }
		
		return path
	}
	
	func deleteAllDownloadedAppContent(for app: DownloadedApps) {
		do {
			CoreDataManager.shared.context.delete(app)
			try FileManager.default.removeItem(at: getFilesForDownloadedApps(for: app, getuuidonly: true))
			try context.save()
		} catch {
			Debug.shared.log(message: "CoreDataManager.deleteAllSignedAppContent: \(error)", type: .error)
		}
	}
	
}
