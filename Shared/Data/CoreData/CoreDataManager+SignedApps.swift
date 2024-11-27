//
//  CoreDataManager+SignedApps.swift
//  feather
//
//  Created by samara on 8/2/24.
//  Copyright (c) 2024 Samara M (khcrysalis)
//

import Foundation
import CoreData

extension CoreDataManager {
	
	/// Clear all signedapps from Core Data and delete files
	func clearSignedApps(
		context: NSManagedObjectContext? = nil) {
			let context = context ?? self.context
			clear(request: SignedApps.fetchRequest(), context: context)
	}
	
	/// Fetch all sources sorted alphabetically by name
	func getDatedSignedApps(
		context: NSManagedObjectContext? = nil) -> [SignedApps] {
			let request: NSFetchRequest<SignedApps> = SignedApps.fetchRequest()
			request.sortDescriptors = [NSSortDescriptor(key: "dateAdded", ascending: false)]
			return (try? (context ?? self.context).fetch(request)) ?? []
	}
	
	/// Add application to downloaded apps
	func addToSignedApps(
		context: NSManagedObjectContext? = nil,
		version: String,
		name: String,
		bundleidentifier: String,
		iconURL: String?,
		dateAdded: Date? = Date(),
		uuid: String,
		appPath: String?,
		timeToLive: Date,
		teamName: String,
		originalSourceURL: URL?,
		completion: @escaping (Result<SignedApps, Error>) -> Void) {
			let context = context ?? self.context
			let newApp = SignedApps(context: context)
			
			newApp.version = version
			newApp.name = name
			newApp.bundleidentifier = bundleidentifier
			newApp.iconURL = iconURL
			newApp.dateAdded = dateAdded
			newApp.uuid = uuid
			newApp.appPath = appPath
			newApp.timeToLive = timeToLive
			newApp.teamName = teamName
			newApp.originalSourceURL = originalSourceURL

			do {
				try context.save()
				NotificationCenter.default.post(name: Notification.Name("lfetch"), object: nil)
				completion(.success(newApp)) // one exception for this single function out of all of them 
			} catch {
				Debug.shared.log(message: "Error saving data: \(error)", type: .error)
				completion(.failure(error))
			}
	}
	
	/// Get application file path
	func getFilesForSignedApps(for app: SignedApps, getuuidonly: Bool = false) -> URL {
		guard let uuid = app.uuid, let appPath = app.appPath, let dir = app.directory else { return URL(string: "")!}
		
		let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
		var path = documentsDirectory
			.appendingPathComponent("Apps")
			.appendingPathComponent(dir)
			.appendingPathComponent(uuid)
		
		if !getuuidonly { path = path.appendingPathComponent(appPath) }
		
		return path
	}
	
	func deleteAllSignedAppContent(for app: SignedApps) {
		do {
			CoreDataManager.shared.context.delete(app)
			try FileManager.default.removeItem(at: getFilesForSignedApps(for: app, getuuidonly: true))
			try context.save()
		} catch {
			Debug.shared.log(message: "CoreDataManager.deleteAllSignedAppContent: \(error)", type: .error)
		}
	}
	
	func updateSignedApp(
		app: SignedApps,
		newTimeToLive: Date,
		newTeamName: String,
		completion: @escaping (Error?) -> Void) {
		
		let context = app.managedObjectContext ?? self.context
		
		app.timeToLive = newTimeToLive
		app.teamName = newTeamName
		
		do {
			try context.save()
			completion(nil)
		} catch {
			Debug.shared.log(message: "Error updating SignedApps: \(error)", type: .error)
			completion(error)
		}
	}
    
    func setUpdateAvailable(for app: SignedApps, newVersion: String) {
        app.hasUpdate = true
        app.updateVersion = newVersion
        saveContext()
    }

    func clearUpdateState(for app: SignedApps) {
        app.hasUpdate = false
        app.updateVersion = nil
        saveContext()
    }
	
}
