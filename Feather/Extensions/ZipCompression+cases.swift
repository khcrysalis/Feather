//
//  ZipCompression+cases.swift
//  Feather
//
//  Created by samara on 22.04.2025.
//

import Zip

extension ZipCompression {
	static var allCases: [ZipCompression] {
		return [.NoCompression, .BestSpeed, .DefaultCompression, .BestCompression]
	}
	
	var label: String {
		switch self {
		case .NoCompression: return "None"
		case .BestSpeed: return "Speed"
		case .DefaultCompression: return "Default"
		case .BestCompression: return "Best"
		}
	}
}
