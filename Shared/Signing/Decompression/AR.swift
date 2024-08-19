//
//  AR.swift
//  feather
//
//  Created by samara on 8/18/24.
//

import Foundation

public struct ARFile {
	var name: String
	var modificationDate: Date
	var ownerId: Int
	var groupId: Int
	var mode: Int
	var size: Int
	var content: Data
}

func removePadding(_ paddedString: String) -> String {
	let data = paddedString.data(using: .utf8)!
		
	guard let firstNonSpaceIndex = data.firstIndex(of: UInt8(ascii: " ")) else {
		return paddedString
	}
	
	let actualData = data[..<firstNonSpaceIndex]
	return String(data: actualData, encoding: .utf8)!
}

enum ARError: Error {
	case badArchive(String)
}

func getFileInfo(_ data: Data, _ offset: Int) throws -> ARFile {
	let size = Int(removePadding(String(data: data.subdata(in: offset+48..<offset+48+10), encoding: .ascii) ?? "0"))!
	if size < 1 {
		throw ARError.badArchive("Invalid size")
	}
	
	let name = removePadding(String(data: data.subdata(in: offset..<offset+16), encoding: .ascii) ?? "")
	guard name != "" else {
		throw ARError.badArchive("Invalid name")
	}
	
	return ARFile(
		name: name,
		modificationDate: NSDate(timeIntervalSince1970: Double(removePadding(String(data: data.subdata(in: offset+16..<offset+16+12), encoding: .ascii) ?? "0"))!) as Date,
		ownerId: Int(removePadding(String(data: data.subdata(in: offset+28..<offset+28+6), encoding: .ascii) ?? "0"))!,
		groupId: Int(removePadding(String(data: data.subdata(in: offset+34..<offset+34+6), encoding: .ascii) ?? "0"))!,
		mode: Int(removePadding(String(data: data.subdata(in: offset+40..<offset+40+8), encoding: .ascii) ?? "0"))!,
		size: size,
		content: data.subdata(in: offset+60..<offset+60+size)
	)
}

public func extractAR(_ rawData: Data) throws -> [ARFile] {
	if [UInt8](rawData.subdata(in: Range(0...7))) != [0x21, 0x3c, 0x61, 0x72, 0x63, 0x68, 0x3e, 0x0a] {
		throw ARError.badArchive("Invalid magic")
	}

	let data = rawData.subdata(in: 8..<rawData.endIndex)
	
	var offset = 0
	var files: [ARFile] = []
	while offset < data.count {
		let fileInfo = try getFileInfo(data, offset)
		files.append(fileInfo)
		offset += fileInfo.size + 60
		offset += offset % 2
	}
	return files
}
