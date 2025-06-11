//
//  UTType+plist.swift
//  Feather
//
//  Created by samara on 20.04.2025.
//


import UniformTypeIdentifiers

extension UTType {
	static var entitlements: UTType {
		UTType(filenameExtension: "entitlements", conformingTo: .data)!
	}
}
