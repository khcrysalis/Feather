//
//  Heartbeat+start.swift
//  Feather
//
//  Created by samara on 29.04.2025.
//

import Foundation
import UIKit
import OSLog

// MARK: - Class extension: start
extension HeartbeatManager {
	/// Starts heartbeat
	/// - Parameter forceRestart: Force restarts heartbeat
	func start(_ forceRestart: Bool = false) {
		restartLock.lock()
		defer { restartLock.unlock() }
		
		restartWorkItem?.cancel()
		restartWorkItem = nil
		
		if isRestartInProgress && !forceRestart {
			Logger.heartbeat.debug("Restart already in progress, ignoring call")
			return
		}
		
		let existingThreadIsActive = heartbeatThread?.isExecuting ?? false
		if forceRestart {
			sessionId = arc4random()
			Logger.heartbeat.info("Forcing heartbeat restart with new session ID")
		} else if existingThreadIsActive {
			Logger.heartbeat.info("Heartbeat thread already running")
			return
		}
		
		if heartbeatThread != nil && !existingThreadIsActive {
			heartbeatThread = nil
		}
		
		isRestartInProgress = true
		
		heartbeatThread = Thread { [weak self] in
			guard let self = self else { return }
			
			self._establishHeartbeat { [weak self] error in
				guard let self = self else { return }
				
				self.restartLock.lock()
				defer { self.restartLock.unlock() }
				
				if let error = error {
					Logger.heartbeat.error("Heartbeat error: \(error.rawValue)")
					self._scheduleRestart()
				} else {
					self.restartBackoffTime = 1.0
					self.isRestartInProgress = false
				}
			}
		}
		
		// Start
		if let thread = heartbeatThread {
			thread.name = "idevice-heartbeat"
			thread.qualityOfService = .background
			thread.start()
			Logger.heartbeat.info("Started new heartbeat thread")
		}
	}
	/// Schedules heartbeat restart if any errors occur
	private func _scheduleRestart() {
		let workItem = DispatchWorkItem { [weak self] in
			guard let self = self else { return }
			
			self.restartLock.lock()
			self.isRestartInProgress = false
			self.restartWorkItem = nil
			self.restartLock.unlock()
			
			self.start()
		}
		
		restartWorkItem = workItem
		restartBackoffTime = min(restartBackoffTime * 1.5, 30.0)
		
		Logger.heartbeat.info("Scheduling restart in \(self.restartBackoffTime) seconds")
		DispatchQueue.main.asyncAfter(deadline: .now() + restartBackoffTime, execute: workItem)
	}
	/// Establishes heartbeat
	/// - Parameter completion: Completes with optionally an idevice error code
	private func _establishHeartbeat(
		completion: @escaping (IdeviceErrorCode?) -> Void
	) {
		guard let pairingFile = getPairing() else {
			completion(nil)
			return
		}
		
		sessionId = arc4random()
		
		guard checkSocketConnection().isConnected else {
			Logger.heartbeat.error("Socket connection check failed - device unreachable")
			completion(NotFound)
			return
		}
		
		_startHeartbeat(
			pairingFile: pairingFile,
			provider: &provider,
			sessionId: sessionId
		) { err in
			completion(err)
		}
	}
	/// Starts heartbeat
	/// - Parameters:
	///   - pairingFile: Pointer to pairing file
	///   - provider: Pointer to TCP Provider
	///   - sessionId: Random sessionID
	///   - completion: Completes with optionally an idevice error code
	private func _startHeartbeat(
		pairingFile: IdevicePairingFile,
		provider: inout TcpProviderHandle?,
		sessionId: UInt32?,
		completion: @escaping (IdeviceErrorCode?) -> Void
	) {
		let currentSession = sessionId
		
		var addr = sockaddr_in()
		memset(&addr, 0, MemoryLayout.size(ofValue: addr))
		addr.sin_family = sa_family_t(AF_INET)
		addr.sin_port = CFSwapInt16HostToBig(port)
		
		guard inet_pton(AF_INET, ipAddress, &addr.sin_addr) == 1 else {
			Logger.heartbeat.error("Invalid IP address")
			completion(UnknownErrorType)
			return
		}
		
		let result = withUnsafePointer(to: &addr) {
			$0.withMemoryRebound(to: sockaddr.self, capacity: 1) { sockaddrPtr in
				idevice_tcp_provider_new(sockaddrPtr, pairingFile, "SS-Provider", &provider)
			}
		}
		
		if result != IdeviceSuccess {
			Logger.heartbeat.error("Failed to create TCP provider: \(result.rawValue)")
			completion(result)
			return
		}
		
		var heartbeatClient: HeartbeatClientHandle?
		let hbConnectResult = heartbeat_connect_tcp(provider, &heartbeatClient)
		if hbConnectResult != IdeviceSuccess {
			Logger.heartbeat.error("Failed to start heartbeat client: \(hbConnectResult.rawValue)")
			
			if hbConnectResult == InvalidHostID, fileManager.fileExists(atPath: Self.pairingFile()) {
				Logger.heartbeat.info("Deleting pairing file, requesting for a new one.")
				try? fileManager.removeItem(atPath: Self.pairingFile())
				
				DispatchQueue.main.async {
					UIAlertController.showAlertWithOk(
						title: "InvalidHostID",
						message: "Your pairing file is invalid and is incompatible with your device, please import a valid pairing file."
					)
				}
			}
			
			completion(hbConnectResult)
			return
		}
		
		completion(nil)
		
		_runHeartbeatLoop(
			heartbeatClient: heartbeatClient!,
			currentSession: currentSession,
			sessionId: sessionId
		)
	}
	/// Runs heartbeat loop
	/// - Parameters:
	///   - heartbeatClient: Heartbeat Client pointer
	///   - currentSession: "Current" sessionID
	///   - sessionId: Random sessionID
	private func _runHeartbeatLoop(
		heartbeatClient: HeartbeatClientHandle,
		currentSession: UInt32?,
		sessionId: UInt32?
	) {
		var currentInterval: UInt64 = 15
		
		while true {
			if sessionId != currentSession {
				break
			}
			
			var nextInterval: UInt64 = 0
			
			let marcoResult = heartbeat_get_marco(heartbeatClient, currentInterval, &nextInterval)
			if marcoResult != IdeviceSuccess {
				Logger.heartbeat.error("heartbeat_get_marco failed: \(marcoResult.rawValue)")
				heartbeat_client_free(heartbeatClient)
				return
			}
			
			DispatchQueue.main.async {
				NotificationCenter.default.post(name: .heartbeat, object: nil)
			}
			
			#if DEBUG
			Logger.heartbeat.debug("bump \(Date.now.formatted(date: .numeric, time: .standard))")
			#endif
			
			currentInterval = nextInterval + 5
			
			let poloResult = heartbeat_send_polo(heartbeatClient)
			if poloResult != IdeviceSuccess {
				Logger.heartbeat.error("heartbeat_send_polo failed: \(poloResult.rawValue)")
				heartbeat_client_free(heartbeatClient)
				return
			}
		}
	}
}
