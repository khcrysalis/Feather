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
	guard getifaddrs(&ifaddr) == 0 else { return nil }
	
	var ptr = ifaddr
	while ptr != nil {
		defer { ptr = ptr?.pointee.ifa_next }
		
		guard let interface = ptr?.pointee,
			  let name = String(cString: interface.ifa_name, encoding: .ascii),
			  name == "en0", // Wi-Fi interface
			  let addr = interface.ifa_addr.pointee.sa_family == UInt8(AF_INET) ? interface.ifa_addr : nil else {
			continue
		}
		
		var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
		if getnameinfo(addr, socklen_t(interface.ifa_addr.pointee.sa_len),
					   &hostname, socklen_t(hostname.count),
					   nil, 0, NI_NUMERICHOST) == 0 {
			address = String(cString: hostname)
		}
	}
	
	freeifaddrs(ifaddr)
	return address
}


extension Installer {
	static let sni = Preferences.userSelectedServer ? (getLocalIPAddress() ?? "app.localhost.direct") : "app.localhost.direct"
	
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
