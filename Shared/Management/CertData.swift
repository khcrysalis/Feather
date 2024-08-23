//
//  CertData.swift
//  feather
//
//  Created by samara on 8/3/24.
//  Copyright (c) 2024 Samara M (khcrysalis)
//

import Foundation

final class CertData {
	static func parseMobileProvisioningFile(atPath path: URL) -> Cert? {
		do {
			let fileData = try Data(contentsOf: path)
			
			guard let xmlRange = fileData.range(of: Data("<?xml".utf8)) else {
				Debug.shared.log(message: "XML start not found in file.", type: .error)
				return nil
			}
			
			let xmlData = fileData.subdata(in: xmlRange.lowerBound..<fileData.endIndex)
			
			let plist = try PropertyListSerialization.propertyList(from: xmlData, options: [], format: nil)
			
			guard let plistDict = plist as? [String: Any] else {
				Debug.shared.log(message: "File does not contain a valid plist dictionary.", type: .error)
				return nil
			}
			
			let appIDName = plistDict["AppIDName"] as? String ?? ""
			let creationDate = plistDict["CreationDate"] as? Date ?? Date()
			let isXcodeManaged = plistDict["IsXcodeManaged"] as? Bool ?? false
			let derEncodedProfile = plistDict["DER-Encoded-Profile"] as? Data ?? Data()
			let ppqCheck = plistDict["PPQCheck"] as? Bool
			let expirationDate = plistDict["ExpirationDate"] as? Date ?? Date()
			let name = plistDict["Name"] as? String ?? ""
			let teamName = plistDict["TeamName"] as? String ?? ""
			let timeToLive = plistDict["TimeToLive"] as? Int ?? 0
			let uuid = plistDict["UUID"] as? String ?? ""
			let version = plistDict["Version"] as? Int ?? 0
			
			return Cert(
				AppIDName: appIDName,
				CreationDate: creationDate,
				IsXcodeManaged: isXcodeManaged,
				derEncodedProfile: derEncodedProfile,
				PPQCheck: ppqCheck,
				ExpirationDate: expirationDate,
				Name: name,
				TeamName: teamName,
				TimeToLive: timeToLive,
				UUID: uuid,
				Version: version
			)
		} catch {
			Debug.shared.log(message: "CertData.parseMobileProvisioningFile: \(error)", type: .error)
			return nil
		}
	}
	
	static func copyFile(from sourceURL: URL?, to destinationDirectory: URL) throws {
		guard let sourceURL = sourceURL else { return }
		let destinationURL = destinationDirectory.appendingPathComponent(sourceURL.lastPathComponent)
		try FileManager.default.copyItem(at: sourceURL, to: destinationURL)
	}
}
