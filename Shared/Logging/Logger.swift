//
//  Logger.swift
//  feather
//
//  Created by samara on 7/29/24.
//

import Foundation
import OSLog

public enum LogType {
	/// Default
	case notice
	/// Call this function to capture information that may be helpful, but isn’t essential, for troubleshooting.
	case info
	/// Debug-level messages to use in a development environment while actively debugging.
	case debug
	/// Equivalent of the debug method.
	case trace
	/// Warning-level messages for reporting unexpected non-fatal failures.
	case warning
	/// Error-level messages for reporting critical errors and failures.
	case error
	/// Fault-level messages for capturing system-level or multi-process errors only.
	case fault
	/// Functional equivalent of the fault method.
	case critical
}

final class Debug {
	static let shared = Debug()
	private let subsystem = Bundle.main.bundleIdentifier!
	
	func log(message: String, type: LogType, function: String = #function, file: String = #file, line: Int = #line) {
		lazy var logger = Logger(subsystem: subsystem, category: file+"->"+function)
		switch type {
		case .info:
			logger.info("\(message)")
		case .debug:
			logger.debug("\(message)")
		case .trace:
			logger.trace("\(message)")
		case .warning:
			logger.warning("\(message)")
		case .error:
			logger.error("\(message)")
		case .fault:
			logger.fault("\(message)")
		case .critical:
			logger.critical("\(message)")
		default:
			logger.log("\(message)")
		}
	}
}
