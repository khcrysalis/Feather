//
//  Heartbeat+checks.swift
//  Feather
//
//  Created by samara on 29.04.2025.
//

import Foundation

// MARK: - Class extension: socket
extension HeartbeatManager {
	/// Check connection to socket/tunnel
	/// - Returns: Tuple for connection status and error message (if any)
	func checkSocketConnection() -> (isConnected: Bool, error: String?) {
		let socketFD = socket(AF_INET, SOCK_STREAM, 0)
		if socketFD == -1 {
			return (false, "Failed to create socket")
		}
		
		defer {
			close(socketFD)
		}
		
		var addr = sockaddr_in()
		memset(&addr, 0, MemoryLayout.size(ofValue: addr))
		addr.sin_family = sa_family_t(AF_INET)
		addr.sin_port = CFSwapInt16HostToBig(port)
		
		guard inet_pton(AF_INET, ipAddress, &addr.sin_addr) == 1 else {
			return (false, "Invalid IP address format")
		}
		
		let connectResult = withUnsafePointer(to: &addr) {
			$0.withMemoryRebound(to: sockaddr.self, capacity: 1) { sockaddrPtr in
				connect(socketFD, sockaddrPtr, socklen_t(MemoryLayout<sockaddr_in>.size))
			}
		}
		
		if connectResult != 0 {
			return (false, "Failed to connect: \(String(cString: strerror(errno)))")
		}
		
		return (true, nil)
	}
	/// Retrieves and reads pairing file (if any)
	/// - Returns: Pointer to pairing file
	func getPairing() -> IdevicePairingFile? {
		guard fileManager.fileExists(atPath: Self.pairingFile()) else {
			return nil
		}
		
		var pairingFile: IdevicePairingFile?
		
		guard idevice_pairing_file_read(Self.pairingFile(), &pairingFile) == IdeviceSuccess else {
			return nil
		}
		
		return pairingFile
	}
}
