//
//  SwiftAR.swift
//  SwiftAR
//
//  Created by nekohaxx on 8/18/24.
//

import Foundation

class AR: NSObject {
	private var _data: Data
	
	init(with url: URL) {
		self._data = try! Data(contentsOf: url)
		super.init()
	}
	
	func extract() async throws -> [ARFileModel] {
		if [UInt8](_data.subdata(in: Range(0...7))) != [0x21, 0x3c, 0x61, 0x72, 0x63, 0x68, 0x3e, 0x0a] {
			throw ARError.badArchive("Invalid magic")
		}
		
		let data = _data.subdata(in: 8..<_data.endIndex)
		
		var offset = 0
		var files: [ARFileModel] = []
		while offset < data.count {
			let fileInfo = try _getFileInfo(data, offset)
			files.append(fileInfo)
			offset += fileInfo.size + 60
			offset += offset % 2
		}
		return files
	}
	
	private func _getFileInfo(_ data: Data, _ offset: Int) throws -> ARFileModel {
		let size = Int(_removePadding(String(data: data.subdata(in: offset+48..<offset+48+10), encoding: .ascii) ?? "0"))!
		if size < 1 {
			throw ARError.badArchive("Invalid size")
		}
		
		let name = _removePadding(String(data: data.subdata(in: offset..<offset+16), encoding: .ascii) ?? "")
		guard name != "" else {
			throw ARError.badArchive("Invalid name")
		}
		
		return ARFileModel(
			name: name,
			modificationDate: NSDate(timeIntervalSince1970: Double(_removePadding(String(data: data.subdata(in: offset+16..<offset+16+12), encoding: .ascii) ?? "0"))!) as Date,
			ownerId: Int(_removePadding(String(data: data.subdata(in: offset+28..<offset+28+6), encoding: .ascii) ?? "0"))!,
			groupId: Int(_removePadding(String(data: data.subdata(in: offset+34..<offset+34+6), encoding: .ascii) ?? "0"))!,
			mode: Int(_removePadding(String(data: data.subdata(in: offset+40..<offset+40+8), encoding: .ascii) ?? "0"))!,
			size: size,
			content: data.subdata(in: offset+60..<offset+60+size)
		)
	}
	
	private func _removePadding(_ paddedString: String) -> String {
		let data = paddedString.data(using: .utf8)!
		
		guard let firstNonSpaceIndex = data.firstIndex(of: UInt8(ascii: " ")) else {
			return paddedString
		}
		
		let actualData = data[..<firstNonSpaceIndex]
		return String(data: actualData, encoding: .utf8)!
	}
}

enum ARError: Error {
	case badArchive(String)
}
