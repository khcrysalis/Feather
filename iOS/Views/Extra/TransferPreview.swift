//
//  TransferPreview.swift
//  feather
//
//  Created by samara on 8/16/24.
//  Copyright © 2024 Lakr Aream. All Rights Reserved.
//  ORIGINALLY LICENSED UNDER GPL-3.0, MODIFIED FOR USE FOR FEATHER
//

import SwiftUI
import UIKit
import SafariServices

struct TransferPreview: View {
	@Environment(\.presentationMode) var presentationMode
	
	@StateObject var installer: Installer
	
	@State var appPath: String
	@State var appName: String
	@State var isSharing: Bool = false
	
	@State private var packaging: Bool = true
	@State private var showShareSheet = false
	@State private var shareURL: URL?

	var icon: String {
		if packaging {
			return "archivebox.fill"
		} else if !isSharing {
			switch installer.status {
			case .ready:
				return "app.gift"
			case .sendingManifest, .sendingPayload:
				return "paperplane.fill"
			case let .completed(result):
				switch result {
				case .success:
					return "app.badge.checkmark"
				case .failure:
					return "exclamationmark.triangle.fill"
				}
			case .broken:
				return "exclamationmark.triangle.fill"
			}
		} else {
			return "checkmark.circle"
		}
	}
	
	var text: String {
		if packaging {
			return String.localized("TRANSFER_PREVIEW_PACKAGING")
		} else if !isSharing {
			switch installer.status {
			case .ready:
				return String.localized("TRANSFER_PREVIEW_READY")
			case .sendingManifest:
				return String.localized("TRANSFER_PREVIEW_SENDING_MANIFEST")
			case .sendingPayload:
				return String.localized("TRANSFER_PREVIEW_SENDING_PAYLOAD")
			case let .completed(result):
				switch result {
				case .success:
					return String.localized("TRANSFER_PREVIEW_DONE")
				case let .failure(failure):
					return failure.localizedDescription
				}
			case let .broken(error):
				return error.localizedDescription
			}
		} else {
			return String.localized("TRANSFER_PREVIEW_COMPLETED")
		}
	}
	
	@State private var isPresentWebView = false
	
	var body: some View {
		VStack {
			Spacer()
			VStack(spacing: 18) {
				Image(systemName: icon)
					.antialiased(true)
					.resizable()
					.cornerRadius(8)
					.frame(width: 42, height: 42, alignment: .center)
				Text(text)
					.font(.system(.body, design: .rounded))
					.bold()
					.frame(alignment: .center)
			}
			.sheet(isPresented: $isPresentWebView) {
				SafariWebView(url: installer.pageEndpoint)
					.ignoresSafeArea()
					
			}
			.onReceive(installer.$status) { newStatus in
				if case .sendingPayload = newStatus, Preferences.userSelectedServer {
					isPresentWebView = false
				}
				
				if case let .completed(result) = newStatus {
					if case .success = result {
						DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
							presentationMode.wrappedValue.dismiss()
						}
					}
				}
			}

			.onAppear {
				archivePayload(at: appPath, with: appName) { archiveURL in
					if let archiveURL = archiveURL {
						installer.package = archiveURL
						if isSharing {
							shareURL = archiveURL
							showShareSheet = true
						} else if case .ready = installer.status {
							if Preferences.userSelectedServer {
								isPresentWebView = true
							} else {
								UIApplication.shared.open(installer.iTunesLink)
							}
						}
					}
				}
			}

			.padding()
			Spacer()
		}
		.popover(isPresented: $showShareSheet) {
			if let shareURL = shareURL {
				ActivityViewController(activityItems: [shareURL])
			}
		}

		.animation(.spring, value: text)
		.animation(.spring, value: icon)
		.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
		.background(Color(UIColor.quaternarySystemFill))
		.cornerRadius(12)
		.padding()
	}
	
	func archivePayload(at filePath: String, with fileName: String, completion: @escaping (URL?) -> Void) {
		DispatchQueue.global(qos: .userInitiated).async {
			let uuid = UUID().uuidString
			let tempDirectory = FileManager.default.temporaryDirectory.appendingPathComponent(uuid)
			let payloadPath = tempDirectory.appendingPathComponent("Payload")
			let sanitizedFileName = fileName.replacingOccurrences(of: "/", with: "_").trimmingCharacters(in: .whitespacesAndNewlines)
			let ipaPath = tempDirectory.appendingPathComponent("\(sanitizedFileName).ipa")
			
			do {
				try FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true)
				try FileManager.default.copyItem(atPath: filePath, toPath: payloadPath.path)
				try FileManager.default.zipItem(at: payloadPath, to: ipaPath)
				
				DispatchQueue.main.async {
					self.packaging = false
					completion(ipaPath)
				}
			} catch {
				Debug.shared.log(message: "Error creating archive: \(error)", type: .error)
				DispatchQueue.main.async {
					completion(nil)
				}
			}
		}
	}

}

struct ActivityViewController: UIViewControllerRepresentable {
	var activityItems: [Any]
	var applicationActivities: [UIActivity]? = nil

	func makeUIViewController(context: UIViewControllerRepresentableContext<ActivityViewController>) -> UIActivityViewController {
		return UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
	}

	func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ActivityViewController>) {}
}

struct SafariWebView: UIViewControllerRepresentable {
	let url: URL
	
	func makeUIViewController(context: Context) -> SFSafariViewController {
		return SFSafariViewController(url: url)
	}
	
	func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {
		//
	}
}
