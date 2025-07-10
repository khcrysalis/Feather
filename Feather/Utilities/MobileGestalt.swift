import Foundation
import Darwin
import OSLog

class MobileGestalt {
    private typealias MGCopyAnswer = @convention(c) (CFString) -> CFTypeRef?
    private let copyAnswerRef: MGCopyAnswer?
    private let handle: UnsafeMutableRawPointer?
    
    init() {
        handle = dlopen("/usr/lib/libMobileGestalt.dylib", RTLD_LAZY)
        if let handleRef = handle, let sym = dlsym(handleRef, "MGCopyAnswer") {
            copyAnswerRef = unsafeBitCast(sym, to: MGCopyAnswer.self)
            Logger.misc.debug("MGCopyAnswer loaded.")
        } else {
            copyAnswerRef = nil
            Logger.misc.error("Failed to load MGCopyAnswer symbol.")
        }
    }

    deinit {
        if let handleRef = handle {
            dlclose(handleRef)
            Logger.misc.debug("dlclose called on MobileGestalt handle.")
        }
    }

    func getPhysicalHardwareNameString() -> String? {
        Logger.misc.debug("Querying MobileGestalt for PhysicalHardwareNameString")
        guard let mgc = copyAnswerRef else { Logger.misc.error("MGCopyAnswer not available"); return nil }
        guard let ref = mgc("PhysicalHardwareNameString" as CFString) else { Logger.misc.debug("No value for PhysicalHardwareNameString"); return nil }
        if CFGetTypeID(ref) == CFStringGetTypeID(), let s = ref as? String { return s }
        return nil
    }
}
