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

// 检测设备是否使用移动数据
func isUsingMobileData() -> Bool {
    var address: String?
    var ifaddr: UnsafeMutablePointer<ifaddrs>?

    if getifaddrs(&ifaddr) == 0 {
        var ptr = ifaddr
        while ptr != nil {
            let interface = ptr!.pointee
            let addrFamily = interface.ifa_addr.pointee.sa_family

            if addrFamily == UInt8(AF_INET) {
                let name = String(cString: interface.ifa_name)
                // 如果是使用移动数据的接口（pdp_ip0）
                if name == "pdp_ip0" {
                    address = String(cString: interface.ifa_name)
                    break
                }
            }
            ptr = ptr!.pointee.ifa_next
        }
        freeifaddrs(ifaddr)
    }

    return address != nil
}

// 获取本地 IP 地址
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
        // 判断是否用户选择了自定义服务器
        if Preferences.userSelectedServer {
            // 如果用户选择了自定义服务器，并且设备使用移动数据，设置为 127.0.0.1
            if isUsingMobileData() {
                return "127.0.0.1"
            }
            // 否则，获取本地 IP 地址
            return getLocalIPAddress() ?? "0.0.0.0"
        } else {
            // 如果用户没有选择自定义服务器，调用 readCommonName() 读取常见名称（通常从文件或配置中读取），如果读取失败则返回 "0.0.0.0"
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
