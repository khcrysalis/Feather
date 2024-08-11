//
//  Logger.swift
//  feather
//
//  Created by samara on 7/29/24.
//

import Foundation
import OSLog
import AlertKit

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
			showSuccessAlert(with: "Success", subtitle: message)
		case .debug:
			logger.debug("\(message)")
		case .trace:
			logger.trace("\(message)")
			showErrorUIAlert(with: "Trace", subtitle: message)
		case .warning:
			logger.warning("\(message)")
			showErrorAlert(with: "Error", subtitle: message)
		case .error:
			logger.error("\(message)")
			showErrorAlert(with: "Error", subtitle: message)
		case .fault:
			logger.fault("\(message)")
			showErrorUIAlert(with: "Fault", subtitle: message)
		case .critical:
			logger.critical("\(message)")
			showErrorUIAlert(with: "Critical", subtitle: message)
		default:
			logger.log("\(message)")
		}
	}
	
	func showSuccessAlert(with title: String, subtitle: String) {
		DispatchQueue.main.async {
			let alertView = AlertAppleMusic17View(title: title, subtitle: subtitle, icon: .done)
			if let viewController = UIApplication.shared.windows.first?.rootViewController {
				alertView.present(on: viewController.view)
			}
			#if os(iOS)
			let generator = UINotificationFeedbackGenerator()
			generator.notificationOccurred(.success)
			#endif
		}
	}
	
	func showErrorAlert(with title: String, subtitle: String) {
		DispatchQueue.main.async {
			let alertView = AlertAppleMusic17View(title: title, subtitle: subtitle, icon: .error)
			if let viewController = UIApplication.shared.windows.first?.rootViewController {
				alertView.present(on: viewController.view)
			}
			#if os(iOS)
			let generator = UINotificationFeedbackGenerator()
			generator.notificationOccurred(.error)
			#endif
		}
	}
	
	func showErrorUIAlert(with title: String, subtitle: String) {
		DispatchQueue.main.async {
			if let rootViewController = UIApplication.shared.keyWindow?.rootViewController {
				let alert = UIAlertController.error(title: title, message: subtitle, actions: [])
				rootViewController.present(alert, animated: true)
			}
			
			#if os(iOS)
			let generator = UINotificationFeedbackGenerator()
			generator.notificationOccurred(.error)
			#endif
		}
	}
	
}

extension UIAlertController {
	static func error(title: String, message: String, actions: [UIAlertAction]) -> UIAlertController {
		let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
		
		alertController.addAction(UIAlertAction(title: "OK", style: .cancel) { _ in
			alertController.dismiss(animated: true)
		})

		for action in actions {
			alertController.addAction(action)
		}
		#if os(iOS)
		let generator = UINotificationFeedbackGenerator()
		generator.notificationOccurred(.error)
		#endif
		return alertController
	}
	
	static func coolAlert(title: String, message: String, actions: [UIAlertAction]) -> UIAlertController {
		let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)

		for action in actions {
			alertController.addAction(action)
		}
		#if os(iOS)
		let generator = UINotificationFeedbackGenerator()
		generator.notificationOccurred(.error)
		#endif
		return alertController
	}
	
}
