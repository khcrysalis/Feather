//
//  Server+TLS.swift
//  feather
//
//  Created by samara on 22.08.2024.
//  Copyright © 2024 Lakr Aream. All Rights Reserved.
//  ORIGINALLY LICENSED UNDER GPL-3.0, MODIFIED FOR USE FOR FEATHER
//

import Foundation
import NIOSSL
import NIOTLS
import Vapor
import SystemConfiguration.CaptiveNetwork

func getLocalIPAddress() -> String? {
	var address: String?
	var ifaddr: UnsafeMutablePointer<ifaddrs>?
	
	if getifaddrs(&ifaddr) == 0 {
		var ptr = ifaddr
		while ptr != nil {
			let interface = ptr!.pointee
			let addrFamily = interface.ifa_addr.pointee.sa_family
			
			if addrFamily == UInt8(AF_INET) {
				
				let name = String(cString: interface.ifa_name)
				if name == "en0" || name == "pdp_ip0" {
					
					var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
					if getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len),
								   &hostname, socklen_t(hostname.count),
								   nil, socklen_t(0), NI_NUMERICHOST) == 0 {
						address = String(cString: hostname)
						Debug.shared.log(message: "Testing (\(name)): \(address!)")
					}
					
				}
			}
			ptr = ptr!.pointee.ifa_next
		}
		freeifaddrs(ifaddr)
	}
	
	return address
}


extension Installer {
	static let commonName = getDocumentsDirectory().appendingPathComponent("commonName.txt")
	
	static let sni: String = {
		if Preferences.userSelectedServer {
			return getLocalIPAddress() ?? "0.0.0.0"
		} else {
			return readCommonName() ?? "0.0.0.0"
		}
	}()
	
	static let documentsKeyURL = getDocumentsDirectory().appendingPathComponent("server.pem")
	static let documentsCrtURL = getDocumentsDirectory().appendingPathComponent("server.crt")

	static func setupTLS() throws -> TLSConfiguration {
		let keyURL = documentsKeyURL
		let crtURL = documentsCrtURL
		
		return try TLSConfiguration.makeServerConfiguration(
			certificateChain: NIOSSLCertificate
				.fromPEMFile(crtURL.path)
				.map { NIOSSLCertificateSource.certificate($0) },
            privateKey: .privateKey(try NIOSSLPrivateKey(file: keyURL.path, format: .pem)))
	}
}

extension Installer {
	static func readCommonName() -> String? {
		do {
			return try String(contentsOf: commonName, encoding: .utf8).trimmingCharacters(in: .whitespacesAndNewlines)
		} catch {
			Debug.shared.log(message: "Error reading commonName file: \(error.localizedDescription)")
			return nil
		}
	}
}
