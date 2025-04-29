//
//  Heartbeat.swift
//  Feather
//
//  Created by samara on 23.04.2025.
//

import Foundation
import UIKit.UIApplication
import Combine

// MARK: - Class
// ـ♡ﮩ٨ـ heartbeat ♪₊˚
class HeartbeatManager {
	static let shared = HeartbeatManager()
	
	typealias IdevicePairingFile = OpaquePointer
	typealias TcpProviderHandle = OpaquePointer
	typealias HeartbeatClientHandle = OpaquePointer
	
	var fileManager = FileManager.default
	var provider: TcpProviderHandle?
	var heartbeatThread: Thread?
	
	var sessionId: UInt32? = nil
	let ipAddress: String = "10.7.0.1"
	let port: UInt16 = UInt16(LOCKDOWN_PORT)
	
	let restartLock = NSLock()
	var isRestartInProgress = false
	var restartBackoffTime: TimeInterval = 1.0
	var restartWorkItem: DispatchWorkItem?
	var firstRun = false
	
	var cancellable: AnyCancellable? // Combine
	
	// One important note is that if a user gets `InvalidHostID -9` from heartbeat
	// we need to ask them to reimport a fresh pairingfile,
	init() {
		#if DEBUG
		idevice_init_logger(IdeviceLogLevel.init(3), Disabled, nil)
		#endif
		
		// On first start, just be a normal run, on second and onwards
		// we force restart it with a different sessionid
		cancellable = NotificationCenter.default
			.publisher(for: UIApplication.willEnterForegroundNotification)
			.receive(on: DispatchQueue.main)
			.sink { notification in
				let forceRestart = self.firstRun
				self.firstRun = true
				self.start(forceRestart)
			}
	}
	/// Returns (idevice) pairing file path
	/// - Returns: `Documents/Feather/pairingFile.plist`
	static func pairingFile() -> String {
		URL.documentsDirectory.appendingPathComponent("pairingFile.plist").path()
	}
}
