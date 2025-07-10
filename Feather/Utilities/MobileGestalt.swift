//
//  MobileGestalt.swift
//  Feather
//
//  Created by Adrian Castro on 9/7/25.
//

import Foundation
import Darwin
import os.log

class MobileGestalt {
    enum Query: String {
        case productName = "ProductName"
        case productType = "ProductType"
        case productVersion = "ProductVersion"
        case buildVersion = "BuildVersion"
        case deviceClass = "DeviceClass"
        case physicalHardwareNameString = "PhysicalHardwareNameString"
        case boardId = "BoardId"
        case deviceColor = "DeviceColor"
        case regionInfo = "RegionInfo"
        case cpuArchitecture = "CPUArchitecture"
        case firmwareVersion = "FirmwareVersion"
        case hwModelStr = "HWModelStr"
        case isVirtualDevice = "IsVirtualDevice"
        case softwareBehavior = "SoftwareBehavior"
        case partitionType = "PartitionType"
    }

    typealias MGCopyAnswer = @convention(c) (CFString) -> CFTypeRef?
    private let copyAnswerRef: MGCopyAnswer?
    private let handle: UnsafeMutableRawPointer?
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "Feather", category: "MobileGestalt")

    init() {
        handle = dlopen("/usr/lib/libMobileGestalt.dylib", RTLD_LAZY)
        if let handleRef = handle, let sym = dlsym(handleRef, "MGCopyAnswer") {
            copyAnswerRef = unsafeBitCast(sym, to: MGCopyAnswer.self)
            logger.debug("MGCopyAnswer loaded.")
        } else {
            copyAnswerRef = nil
            logger.error("Failed to load MGCopyAnswer symbol.")
        }
    }
    
    deinit {
        if let handleRef = handle {
            dlclose(handleRef)
            logger.debug("dlclose called on MobileGestalt handle.")
        }
    }

    func getValue(for query: Query) -> String? {
        logger.debug("Querying MobileGestalt for key: \(query.rawValue)")
        guard let mgc = copyAnswerRef else { logger.error("MGCopyAnswer not available"); return nil }
        guard let ref = mgc(query.rawValue as CFString) else { logger.debug("No value for key: \(query.rawValue)"); return nil }
        return cfStringer(ref)
    }

    private func cfStringer(_ ref: CFTypeRef?) -> String? {
        guard let ref = ref else { return nil }
        let typeID = CFGetTypeID(ref)
        if typeID == CFStringGetTypeID(), let s = ref as? String { return s }
        if typeID == CFBooleanGetTypeID(), let b = ref as? Bool { return String(b) }
        if typeID == CFNumberGetTypeID(), let n = ref as? NSNumber { return n.stringValue }
        if typeID == CFDataGetTypeID(), let d = ref as? Data, let s = String(data: d, encoding: .utf8) { return s.trimmingCharacters(in: .newlines) }
        return nil
    }
}
