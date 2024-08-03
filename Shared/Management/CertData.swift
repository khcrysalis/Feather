//
//  CertData.swift
//  feather
//
//  Created by samara on 8/3/24.
//

import Foundation

final class CertData {
	static func readMobileProvisionFile(atPath path: String) -> String? {
		do {
			let fileContent = try String(contentsOfFile: path, encoding: .ascii)
			
			if fileContent.contains("<?xml") && fileContent.contains("<plist") && fileContent.contains("<dict>") && fileContent.contains("TimeToLive") {
				return fileContent
			} else {
				print("File does not appear to be a valid mobile provisioning file?")
				return nil
			}
		} catch {
			print("Error reading file: \(error)")
			return nil
		}
	}

	static func extractPlist(fromMobileProvision fileContent: String) -> String? {
		guard let startRange = fileContent.range(of: "<?xml"),
			  let endRange = fileContent.range(of: "</plist>") else {
			return nil
		}
		
		let plistContent = fileContent[startRange.lowerBound..<endRange.upperBound]
		return String(plistContent)
	}
	
	static func copyFile(from sourceURL: URL?, to destinationDirectory: URL) throws {
		guard let sourceURL = sourceURL else { return }
		let destinationURL = destinationDirectory.appendingPathComponent(sourceURL.lastPathComponent)
		try FileManager.default.copyItem(at: sourceURL, to: destinationURL)
	}
}
