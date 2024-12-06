//
//  Logger.swift
//  feather
//
//  Created by samara on 7/29/24.
//  Copyright (c) 2024 Samara M (khcrysalis)
//

import AlertKit
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
	
    case success
}

final class Debug {
    static let shared = Debug()
    private let subsystem = Bundle.main.bundleIdentifier!
	
    private var logFilePath: URL {
        return getDocumentsDirectory().appendingPathComponent("logs.txt")
    }
	
    private func appendLogToFile(_ message: String) {
        do {
            if FileManager.default.fileExists(atPath: logFilePath.path) {
                let fileHandle = try FileHandle(forUpdating: logFilePath)
                fileHandle.seekToEndOfFile()
                if let data = message.data(using: .utf8) {
                    fileHandle.write(data)
                }
                fileHandle.closeFile()
            }
        } catch {
            Debug.shared.log(message: "Error writing to logs.txt: \(error)")
        }
    }
	
    func log(message: String, type: LogType? = nil, function: String = #function, file: String = #file, line: Int = #line) {
        lazy var logger = Logger(subsystem: subsystem, category: file + "->" + function)

        // Prepare the emoji based on the log type
        var emoji: String
        switch type {
        case .success:
            emoji = "✅"
            logger.info("\(message)")
            showSuccessAlert(with: String.localized("ALERT_SUCCESS"), subtitle: message)
        case .info:
            emoji = "ℹ️"
            logger.info("\(message)")
        case .debug:
            emoji = "🐛"
            logger.debug("\(message)")
        case .trace:
            emoji = "🔍"
            logger.trace("\(message)")
            showErrorUIAlert(with: String.localized("ALERT_TRACE"), subtitle: message)
        case .warning:
            emoji = "⚠️"
            logger.warning("\(message)")
            showErrorAlert(with: String.localized("ALERT_ERROR"), subtitle: message)
        case .error:
            emoji = "❌"
            logger.error("\(message)")
            showErrorAlert(with: String.localized("ALERT_ERROR"), subtitle: message)
        case .critical:
            emoji = "🔥"
            logger.critical("\(message)")
            showErrorUIAlert(with: String.localized("ALERT_CRITICAL"), subtitle: message)
        default:
            emoji = "📝"
            logger.log("\(message)")
        }
		
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        let timeString = dateFormatter.string(from: Date())

        let logMessage = "[\(timeString)] \(emoji) \(message)\n"
        appendLogToFile(logMessage)
    }

    func showSuccessAlert(with title: String, subtitle: String) {
        DispatchQueue.main.async {
            let alertView = AlertAppleMusic17View(title: title, subtitle: subtitle, icon: .done)
            let keyWindow = UIApplication.shared.connectedScenes.compactMap { ($0 as? UIWindowScene)?.keyWindow }.last
            if let viewController = keyWindow?.rootViewController {
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
            let keyWindow = UIApplication.shared.connectedScenes.compactMap { ($0 as? UIWindowScene)?.keyWindow }.last
            if let viewController = keyWindow?.rootViewController {
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
            let keyWindow = UIApplication.shared.connectedScenes.compactMap { ($0 as? UIWindowScene)?.keyWindow }.last
            if let rootViewController = keyWindow?.rootViewController {
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
		
        alertController.addAction(UIAlertAction(title: String.localized("OK"), style: .cancel) { _ in
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
