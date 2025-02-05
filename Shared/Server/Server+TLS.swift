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
