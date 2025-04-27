//
//  InstallPreview.swift
//  Feather
//
//  Created by samara on 22.04.2025.
//

import SwiftUI
#if SERVER
import SafariServices
#endif

// MARK: - View
struct InstallPreviewView: View {
	@Environment(\.dismiss) var dismiss
	#if SERVER
	@AppStorage("Feather.serverMethod") private var _serverMethod: Int = 0
	@State private var _isWebviewPresenting = false
	#endif
	
	var app: AppInfoPresentable
	@StateObject var viewModel: StatusViewModel
	#if SERVER
	@StateObject var installer: ServerInstaller
	#endif
	@State var isSharing: Bool

	init(app: AppInfoPresentable, isSharing: Bool = false) {
		self.app = app
		self.isSharing = isSharing
		let viewModel = StatusViewModel()
		self._viewModel = StateObject(wrappedValue: viewModel)
		#if SERVER
		self._installer = StateObject(wrappedValue: try! ServerInstaller(app: app, viewModel: viewModel))
		#endif
	}
	
	// MARK: Body
	var body: some View {
		ZStack {
			InstallProgressView(app: app, viewModel: viewModel)
			_status()
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
		.background(Color(UIColor.secondarySystemBackground))
		.cornerRadius(12)
		.padding()
		#if SERVER
		.sheet(isPresented: $_isWebviewPresenting) {
			SafariWebView(url: installer.pageEndpoint)
				.ignoresSafeArea()
		}
		.onReceive(viewModel.$status) { newStatus in
			#if DEBUG
			print(newStatus)
			#endif
			if case .ready = newStatus {
				if _serverMethod == 0 {
					UIApplication.shared.open(URL(string: installer.iTunesLink)!)
				} else if _serverMethod == 1 {
					_isWebviewPresenting = true
				}
			}
			
			if case .sendingPayload = newStatus, _serverMethod == 1 {
				_isWebviewPresenting = false
			}
		}
		#endif
		.onAppear(perform: _install)
	}
	
	#if SERVER
	struct SafariWebView: UIViewControllerRepresentable {
		let url: URL
		func makeUIViewController(context: Context) -> SFSafariViewController { return SFSafariViewController(url: url) }
		func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
	}
	#endif
	
	
	@ViewBuilder
	private func _status() -> some View {
		Label(viewModel.statusLabel, systemImage: viewModel.statusImage)
			.padding()
			.labelStyle(.titleAndIcon)
			.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
			.animation(.smooth, value: viewModel.statusImage)
	}
	
	private func _install() {
		Task.detached {
			do {
				let handler = await ArchiveHandler(app: app, viewModel: viewModel)
				try await handler.move()
				
				let packageUrl = try await handler.archive()
				
				if await !isSharing {
					#if SERVER
					await MainActor.run {
						installer.packageUrl = packageUrl
						viewModel.status = .ready
					}
					#elseif IDEVICE
					let handler = await ConduitInstaller(viewModel: viewModel)
					try await handler.install(at: packageUrl)
					#endif
				} else {
					try await handler.moveToArchiveAndOpen(packageUrl)
					await MainActor.run {
						dismiss()
					}
				}
			} catch {
				print(error)
			}
		}
	}
}
