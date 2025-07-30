//
//  UTType+ipa.swift
//  Feather
//
//  Created by samara on 11.04.2025.
//

import UniformTypeIdentifiers

extension UTType {
	static var dylib: UTType = .init(filenameExtension: "dylib")!
	static var deb: UTType = .init(filenameExtension: "deb")!
	static var ipa: UTType = .init(filenameExtension: "ipa")!
	static var tipa: UTType = .init(filenameExtension: "tipa")!
	static var entitlements: UTType = .init(filenameExtension: "entitlements", conformingTo: .data)!
	static var p12: UTType = .init(filenameExtension: "p12", conformingTo: .data)!
	static var mobileProvision: UTType = .init(filenameExtension: "mobileprovision", conformingTo: .data)!
}
