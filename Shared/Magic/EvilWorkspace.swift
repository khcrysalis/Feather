//
//  EvilWorkspace.swift
//  feather
//
//  Created by fridakitten on 04.05.25.
//

func EvilRestart() {
    /// Use EvilWorkspace vulnerability, specifically its restart method
    ///
    /// https://https://github.com/seanistethered/EvilWorkspace
    ///
    let workspace = LSApplicationWorkspace.default()
    
    if let workspace = workspace {
        DispatchQueue.global().async {
            while true {
                workspace.openApplication(withBundleID: Bundle.main.bundleIdentifier)
            }
        }
        DispatchQueue.global().async {
            // Do IGNORE the error the debugger gives!!
            UIControl().sendAction(#selector(NSXPCConnection.suspend),
                                   to: UIApplication.shared, for: nil)
        }
    }
}
