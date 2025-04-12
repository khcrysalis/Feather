//
//  UTType+ipa.swift
//  Feather
//
//  Created by samara on 11.04.2025.
//

import UniformTypeIdentifiers

extension UTType {
	static var ipa: UTType {
		UTType(filenameExtension: "ipa")!
	}
	
	static var tipa: UTType {
		UTType(filenameExtension: "tipa")!
	}
}
