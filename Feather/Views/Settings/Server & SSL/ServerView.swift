//
//  ServerView.swift
//  Feather
//
//  Created by samara on 6.05.2025.
//

import SwiftUI
import NimbleJSON
import NimbleViews

struct ServerView: View {
	@AppStorage("Feather.ipFix") private var _ipFix: Bool = false
	@AppStorage("Feather.serverMethod") private var _serverMethod: Int = 0
	private let _serverMethods = ["Fully Local", "Semi Local"]
	
	private let _dataService = NBFetchService()
	private let _serverPackUrl = "https://backloop.dev/pack.json"
	
	var body: some View {
		NBList("Server & SSL") {
			Section {
				Picker("Installation Type", systemImage: "server.rack", selection: $_serverMethod) {
					ForEach(_serverMethods.indices, id: \.self) { index in
						Text(_serverMethods[index]).tag(index)
					}
				}
				Toggle("Only use localhost address", systemImage: "lifepreserver", isOn: $_ipFix)
					.disabled(_serverMethod != 1)
			}
			
			Section {
				Button("Update SSL Certificates", systemImage: "arrow.down.doc") {
					FR.downloadSSLCertificates(from: _serverPackUrl) { success in
						if !success {
							DispatchQueue.main.async {
								UIAlertController.showAlertWithOk(
									title: "SSL Certificates",
									message: "Failed to download, check your internet connection and try again."
								)
							}
						}
					}
					
				}
			}
		}
		.onChange(of: _serverMethod) { _ in
			UIAlertController.showAlertWithRestart(
				title: "Restart Required",
				message: "These changes require a restart of the app"
			)
		}
	}
}
