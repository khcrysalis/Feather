//
//  UTType+ipa.swift
//  Feather
//
//  Created by samara on 11.04.2025.
//

import UniformTypeIdentifiers

extension UTType {
	static var p12: UTType {
		UTType(filenameExtension: "p12", conformingTo: .data)!
	}
	
	static var mobileProvision: UTType {
		UTType(filenameExtension: "mobileprovision", conformingTo: .data)!
	}
}
