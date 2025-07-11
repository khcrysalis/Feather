import Foundation
import Darwin
import OSLog

class MobileGestalt {
    private typealias MGCopyAnswer = @convention(c) (CFString) -> CFTypeRef?
    private let _copyAnswerRef: MGCopyAnswer?
    private let _handle: UnsafeMutableRawPointer?
    
    init() {
        _handle = dlopen("/usr/lib/libMobileGestalt.dylib", RTLD_LAZY)
		
        if
			let _handle,
			let sym = dlsym(_handle, "MGCopyAnswer")
		{
            _copyAnswerRef = unsafeBitCast(sym, to: MGCopyAnswer.self)
        } else {
            _copyAnswerRef = nil
        }
    }

    deinit {
        if let _handle {
            dlclose(_handle)
        }
    }

	func getStringForName(_ name: String) -> String? {
        guard let mgc = _copyAnswerRef else { return nil }
        guard let ref = mgc(name as CFString) else { return nil }
		
        if
			CFGetTypeID(ref) == CFStringGetTypeID(),
			let s = ref as? String
		{
			return s
		}
		
        return nil
    }
}
