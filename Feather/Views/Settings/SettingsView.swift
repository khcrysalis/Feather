//
//  SettingsView.swift
//  Feather
//
//  Created by samara on 10.04.2025.
//

import SwiftUI
import Zip

// MARK: - View
struct SettingsView: View {
	@AppStorage("Feather.compressionLevel") private var _compressionLevel: Int = ZipCompression.DefaultCompression.rawValue
	#if SERVER
	@AppStorage("Feather.ipFix") private var _ipFix: Bool = false
	@AppStorage("Feather.serverMethod") private var _serverMethod: Int = 0
	private let _serverMethods = ["Fully Local", "Semi Local"]
	
	@State private var _isRestartAlertPresenting = false
	#endif
	
	// MARK: Body
    var body: some View {
		FRNavigationView("Settings") {
            List {
				FRSection("Signing") {
					NavigationLink("Certificates", destination: CertificatesView())
					NavigationLink("Configuration", destination: ConfigurationView())
				}
				
				#if SERVER
				FRSection("Server") {
					Picker("Installation Type", selection: $_serverMethod) {
						ForEach(_serverMethods.indices, id: \.self) { index in
							Text(_serverMethods[index]).tag(index)
						}
					}
					Toggle("Only use localhost address", isOn: $_ipFix)
						.disabled(_serverMethod != 1)
				}
				#endif
				
				FRSection("Archive") {
					Picker("Compression Level", selection: $_compressionLevel) {
						ForEach(ZipCompression.allCases, id: \.rawValue) { level in
							Text(level.label).tag(level)
						}
					}
				}
            }
			#if SERVER
			.onChange(of: _serverMethod) { _ in
				_isRestartAlertPresenting = true
			}
			.alert(isPresented: $_isRestartAlertPresenting) {
				Alert(
					title: Text("Restart Required"),
					message: Text("These changes require a restart of the app"),
					dismissButton: .default(Text("OK")) {
						UIApplication.shared.suspend()
					}
				)
			}
			#endif
        }
    }
}
