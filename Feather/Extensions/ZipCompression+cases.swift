//
//  ZipCompression+cases.swift
//  Feather
//
//  Created by samara on 22.04.2025.
//

import Zip

extension ZipCompression {
	static var allCases: [ZipCompression] {
		[.NoCompression, .BestSpeed, .DefaultCompression, .BestCompression]
	}
	
	var label: String {
		switch self {
		case .NoCompression: return .localized("None")
		case .BestSpeed: return .localized("Speed")
		case .DefaultCompression: return .localized("Default")
		case .BestCompression: return .localized("Best")
		}
	}
}
