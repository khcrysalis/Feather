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
		case .NoCompression: .localized("None")
		case .BestSpeed: .localized("Speed")
		case .DefaultCompression: .localized("Default")
		case .BestCompression: .localized("Best")
		}
	}
}
