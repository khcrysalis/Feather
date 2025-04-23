//
//  InstallPreview.swift
//  Feather
//
//  Created by samara on 22.04.2025.
//

import SwiftUI
import SafariServices

// MARK: - View
struct InstallPreview: View {
	@Environment(\.dismiss) var dismiss
	#if SERVER
	@AppStorage("Feather.serverMethod") private var _serverMethod = 0
	@State private var isPresentWebView = false
	#endif
	
	var app: AppInfoPresentable
	#if SERVER
	@StateObject private var installer: Installer
	#endif
	@State var isSharing: Bool
	
	init(app: AppInfoPresentable, isSharing: Bool = false) {
		self.app = app
		self.isSharing = isSharing
		#if SERVER
		let installer = try! Installer(app: app)
		self._installer = StateObject(wrappedValue: installer)
		#endif
	}
	
	// MARK: Body
	var body: some View {
		VStack(spacing: 12) {
			_status()
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
		.background(Color(UIColor.secondarySystemBackground))
		.cornerRadius(12)
		.padding()
		#if SERVER
		.sheet(isPresented: $isPresentWebView) {
			SafariWebView(url: installer.pageEndpoint)
				.ignoresSafeArea()
		}
		#endif
		.task { do {
			let handler = ArchiveHandler(app: app)
			try? await handler.move()
			
			let packageUrl = try? await handler.archive()
			
			if !isSharing {
				#if SERVER
				installer.packageUrl = packageUrl
				installer.status = .ready
				#endif
			} else {
				try? await handler.moveToArchiveAndOpen(packageUrl!)
				dismiss()
			}
		}}
		#if SERVER
		.onReceive(installer.$status) { newStatus in
			print(newStatus)
			if case .ready = newStatus {
				if _serverMethod == 0 {
					UIApplication.shared.open(URL(string: installer.iTunesLink)!)
				} else if _serverMethod == 1 {
					isPresentWebView = true
				}
			}
		}
		.animation(.smooth, value: installer.status.statusImage)
		#endif
	}
	@ViewBuilder
	private func _status() -> some View {
		#if SERVER
		Image(systemName: installer.status.statusImage)
			.resizable()
			.scaledToFit()
			.frame(width: 37, height: 37)
		
		Text(installer.status.statusLabel)
			.font(.headline)
			.multilineTextAlignment(.center)
		#endif
	}
}

#if SERVER
struct SafariWebView: UIViewControllerRepresentable {
	let url: URL
	func makeUIViewController(context: Context) -> SFSafariViewController { return SFSafariViewController(url: url) }
	func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}
#endif
