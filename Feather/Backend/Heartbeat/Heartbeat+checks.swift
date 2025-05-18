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
	func checkSocketConnection(timeoutInSeconds: Double = 2.0) -> (isConnected: Bool, error: String?) {
		let socketFD = socket(AF_INET, SOCK_STREAM, 0)
		if socketFD == -1 {
			return (false, "Failed to create socket")
		}
		
		defer {
			close(socketFD)
		}
		
		let flags = fcntl(socketFD, F_GETFL, 0)
		if flags == -1 {
			return (false, "Failed to get socket flags")
		}
		if fcntl(socketFD, F_SETFL, flags | O_NONBLOCK) == -1 {
			return (false, "Failed to set socket to non-blocking mode")
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
			if errno != EINPROGRESS {
				return (false, "Failed to connect: \(String(cString: strerror(errno)))")
			}
			
			let writeFds = fd_set()
			var writeSet = fd_set()
			__darwin_fd_set(socketFD, &writeSet)
			
			var timeout = timeval()
			timeout.tv_sec = Int(timeoutInSeconds)
			timeout.tv_usec = __darwin_suseconds_t(Int((timeoutInSeconds - Double(timeout.tv_sec)) * 1_000_000))
			
			let selectResult = select(socketFD + 1, nil, &writeSet, nil, &timeout)
			
			if selectResult == 0 {
				return (false, "Connection timed out")
			} else if selectResult == -1 {
				return (false, "Select failed: \(String(cString: strerror(errno)))")
			}
			
			var error: Int32 = 0
			var len = socklen_t(MemoryLayout<Int32>.size)
			if getsockopt(socketFD, SOL_SOCKET, SO_ERROR, &error, &len) == -1 {
				return (false, "Failed to get socket options")
			}
			
			if error != 0 {
				return (false, "Connection failed: \(String(cString: strerror(error)))")
			}
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
