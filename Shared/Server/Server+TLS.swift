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
			
			if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
				
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
	static let sni = Preferences.userSelectedServer ? (getLocalIPAddress() ?? "127.0.0.1") : "app.localhost.direct"
	
	static let bundleKeyURL = Bundle.main.url(forResource: "localhost.direct", withExtension: "pem")
	static let bundleCrtURL = Bundle.main.url(forResource: "localhost.direct", withExtension: "crt")
	
	static let documentsKeyURL = getDocumentsDirectory().appendingPathComponent("localhost.direct.pem")
	static let documentsCrtURL = getDocumentsDirectory().appendingPathComponent("localhost.direct.crt")

	static func setupTLS() throws -> TLSConfiguration {
		let keyURL = FileManager.default.fileExists(atPath: documentsKeyURL.path) ? documentsKeyURL : bundleKeyURL
		let crtURL = FileManager.default.fileExists(atPath: documentsCrtURL.path) ? documentsCrtURL : bundleCrtURL
		
		guard let crtURL, let keyURL else {
			throw NSError(domain: "Installer", code: 0, userInfo: [
				NSLocalizedDescriptionKey: "Failed to load SSL certificates",
			])
		}
		
		return try TLSConfiguration.makeServerConfiguration(
			certificateChain: NIOSSLCertificate
				.fromPEMFile(crtURL.path)
				.map { NIOSSLCertificateSource.certificate($0) },
			privateKey: .file(keyURL.path)
		)
	}
}
