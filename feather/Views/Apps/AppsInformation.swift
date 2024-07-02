//
//  AppsInformation.swift
//  feather
//
//  Created by samara on 7/1/24.
//

import Foundation
import UIKit
import CoreData

extension AppsViewController {
	func getApplicationFilePath(with app: NSManagedObject, row: Int, getuuidonly: Bool = false) -> URL {
		let source = getApplication(row: row)
		var path = ""
		switch segmentedControl.selectedSegmentIndex {
		case 0:
			path = "Unsigned"
		case 1:
			path = "Signed"
		default:
			break
		}
		
		if let uuid = source!.value(forKey: "uuid") as? String,
		   let appPath = source!.value(forKey: "appPath") as? String {
			
			let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
			var p = documentsDirectory
				.appendingPathComponent("Apps")
				.appendingPathComponent(path)
				.appendingPathComponent(uuid)
			
			if !getuuidonly {
				p = p.appendingPathComponent(appPath)
			}
				
			return p
		}
		
		return URL(string: "")!
	}
	
	func getApplication(row: Int) -> NSManagedObject? {
		var source: NSManagedObject?
		switch segmentedControl.selectedSegmentIndex {
		case 0:
			source = downlaodedApps?[row]
			return source
		case 1:
			source = signedApps?[row]
			return source
		default:
			return nil
		}
	}
	
	func loadImage(from iconUrl: URL?) -> UIImage? {
		guard let iconUrl = iconUrl else { return nil }
		return UIImage(contentsOfFile: iconUrl.path)
	}
}

