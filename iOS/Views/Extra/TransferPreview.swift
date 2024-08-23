//
//  TransferPreview.swift
//  feather
//
//  Created by samara on 8/16/24.
//

import SwiftUI
import UIKit

struct TransferPreview: View {
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
			return "Packaging..."
		} else if !isSharing {
			switch installer.status {
			case .ready:
				return "Ready To Install"
			case .sendingManifest:
				return "Sending Manifest..."
			case .sendingPayload:
				return "Sending Payload..."
			case let .completed(result):
				switch result {
				case .success:
					return "Done."
				case let .failure(failure):
					return failure.localizedDescription
				}
			case let .broken(error):
				return error.localizedDescription
			}
		} else {
			return "Completed"
		}
	}
	
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
			.onAppear {
				archivePayload(at: appPath, with: appName) { archiveURL in
					if let archiveURL = archiveURL {
						installer.package = archiveURL
						if isSharing {
							shareURL = archiveURL
							showShareSheet = true
						} else if case .ready = installer.status {
							UIApplication.shared.open(installer.iTunesLink)
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
