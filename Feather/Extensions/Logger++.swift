//
//  Logger++.swift
//  Feather
//
//  Created by samara on 24.05.2025.
//

import OSLog

extension Logger {
	private static var subsystem = Bundle.main.bundleIdentifier!
	static let signing = Logger(subsystem: subsystem, category: "Signing")
	static let heartbeat = Logger(subsystem: subsystem, category: "Heartbeat")
	static let misc = Logger(subsystem: subsystem, category: "Misc")
}
