//
//  Heartbeat.swift
//  Feather
//
//  Created by samara on 23.04.2025.
//

import Foundation

class HeartbeatManager {
	static let shared = HeartbeatManager()
	
	typealias IdevicePairingFile = OpaquePointer
	typealias TcpProviderHandle = OpaquePointer
	typealias HeartbeatClientHandle = OpaquePointer
	
	var provider: TcpProviderHandle?
	private var _heartbeatThread: Thread?
	
	let pairingFilePath: String = HeartbeatManager.pairingFile()
	let ipAddress: String = "10.7.0.1"
	let port: UInt16 = UInt16(LOCKDOWN_PORT)
	
	func start() {
		_heartbeatThread = Thread {
			self._establishHeartbeat { error in
				if let error = error {
					print("Heartbeat error: \(error)")
					self.retry()
				}
			}
		}
		
		if let thread = _heartbeatThread {
			thread.name = "idevice-heartbeat"
			thread.qualityOfService = .background
			thread.start()
		}
	}
	
	private func retry() {
		DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 2) {
			self.start()
		}
	}
	
	private func _establishHeartbeat(completion: @escaping (IdeviceErrorCode?) -> Void) {
		var addr = sockaddr_in()
		memset(&addr, 0, MemoryLayout.size(ofValue: addr))
		addr.sin_family = sa_family_t(AF_INET)
		addr.sin_port = CFSwapInt16HostToBig(port)
		
		guard inet_pton(AF_INET, ipAddress, &addr.sin_addr) == 1 else {
			print("Invalid IP address")
			completion(UnknownErrorType)
			return
		}
		
		var pairingFile: IdevicePairingFile?
		let readResult = idevice_pairing_file_read(pairingFilePath, &pairingFile)
		if readResult != IdeviceSuccess {
			print("Failed to read pairing file: \(readResult)")
			completion(readResult)
			return
		}
		
		print("found pairing!")
		
		let result = withUnsafePointer(to: &addr) {
			$0.withMemoryRebound(to: sockaddr.self, capacity: 1) { sockaddrPtr in
				idevice_tcp_provider_new(sockaddrPtr, pairingFile, "SS-Provider", &self.provider)
			}
		}
		
		if result != IdeviceSuccess {
			print("Failed to create TCP provider: \(result)")
			completion(result)
			return
		}
		
		var heartbeatClient: HeartbeatClientHandle?
		let hbConnectResult = heartbeat_connect_tcp(provider, &heartbeatClient)
		if hbConnectResult != IdeviceSuccess {
			print("Failed to start heartbeat client: \(hbConnectResult)")
			completion(hbConnectResult)
			return
		}
				
		completion(nil)
		
		var currentInterval: UInt64 = 5
		
		while true {
			var nextInterval: UInt64 = 0
			
			let marcoResult = heartbeat_get_marco(heartbeatClient, currentInterval, &nextInterval)
			if marcoResult != IdeviceSuccess {
				print("heartbeat_get_marco failed: \(marcoResult)")
				heartbeat_client_free(heartbeatClient)
				retry()
				return
			}
			
			print("bump \(Date.now.formatted())")
			
			currentInterval = nextInterval + 1
			
			let poloResult = heartbeat_send_polo(heartbeatClient)
			if poloResult != IdeviceSuccess {
				print("heartbeat_send_polo failed: \(poloResult)")
				heartbeat_client_free(heartbeatClient)
				retry()
				return
			}
		}
	}
	
	static func pairingFile() -> String {
		URL.documentsDirectory.appendingPathComponent("pairingFile.plist").path()
	}
}
