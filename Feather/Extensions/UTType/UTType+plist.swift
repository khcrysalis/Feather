//
//  UTType+plist.swift
//  Feather
//
//  Created by samara on 20.04.2025.
//


import UniformTypeIdentifiers

extension UTType {
	static var plist: UTType {
		UTType(filenameExtension: "plist", conformingTo: .data)!
	}
	
	static var mobiledevicepairing: UTType {
		UTType(filenameExtension: "mobiledevicepairing", conformingTo: .data)!
	}
	
	static var entitlements: UTType {
		UTType(filenameExtension: "entitlements", conformingTo: .data)!
	}
}
