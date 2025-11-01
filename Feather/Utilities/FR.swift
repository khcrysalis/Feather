//
//  FR.swift
//  Feather
//
//  Created by samara on 22.04.2025.
//

import Foundation.NSURL
import UIKit.UIImage
import Zsign
import NimbleJSON
import AltSourceKit
import IDeviceSwift
import OSLog

enum FR {
	/// Handle incoming file from share sheet or file provider
	/// This method immediately copies the file while security-scoped access is valid
	static func handleIncomingFile(_ url: URL) {
		// Dismiss any open signing view to show import progress
		DispatchQueue.main.async {
			NotificationCenter.default.post(
				name: Notification.Name("Feather.dismissSigningView"),
				object: nil
			)
		}
		
		Logger.misc.info("[ShareSheet] 🎯 Attempting to import file from: \(url.path)")
		Logger.misc.info("[ShareSheet] 📁 File exists: \(FileManager.default.fileExists(atPath: url.path))")
		Logger.misc.info("[ShareSheet] 🔑 Checking security-scoped access...")
		
		// Request access for security-scoped resources (required for share sheet files)
		let didStartAccessing = url.startAccessingSecurityScopedResource()
		Logger.misc.info("[ShareSheet] ✅ Security-scoped access granted: \(didStartAccessing)")
		
		// IMPORTANT: Copy file immediately while we have security-scoped access
		// The file might be in a temporary location that gets cleaned up quickly
		let fileManager = FileManager.default
		let tempDir = fileManager.temporaryDirectory.appendingPathComponent("FeatherIncoming_\(UUID().uuidString)", isDirectory: true)
		
		do {
			try fileManager.createDirectory(at: tempDir, withIntermediateDirectories: true)
			let tempFileURL = tempDir.appendingPathComponent(url.lastPathComponent)
			let originalFileName = url.lastPathComponent
			
			Logger.misc.info("[ShareSheet] 📋 Copying file to temp location: \(tempFileURL.path)")
			try fileManager.copyItem(at: url, to: tempFileURL)
			Logger.misc.info("[ShareSheet] ✅ File copied successfully to temp location")
			
			// Release security-scoped resource now that we've copied the file
			if didStartAccessing {
				Logger.misc.info("[ShareSheet] 🔓 Releasing security-scoped resource")
				url.stopAccessingSecurityScopedResource()
			}
			
			// Create Download object to show progress UI (like manual import)
			let downloadManager = DownloadManager.shared
			let downloadId = "FeatherManualDownload_\(UUID().uuidString)"
			let download = downloadManager.startArchive(from: tempFileURL, id: downloadId)
			Logger.misc.info("[ShareSheet] 📊 Created download object for progress tracking")
			
			// Set preparing state to show spinner during hash calculation
			DispatchQueue.main.async {
				download.isPreparing = true
			}
			
			// Calculate hash in background
			DispatchQueue.global(qos: .userInitiated).async {
				Logger.misc.info("[ShareSheet] 🔐 Calculating file hash...")
				let fileHash = tempFileURL.sha256Hash()
				
				if let hash = fileHash {
					Logger.misc.info("[ShareSheet] ✅ File hash: \(hash.prefix(16))...")
					
					// Check for duplicates on main thread
					DispatchQueue.main.async {
						if let duplicate = Storage.shared.findDuplicateImported(hash: hash) {
							Logger.misc.warning("[ShareSheet] ⚠️ Found duplicate: \(duplicate.name ?? "Unknown")")
							
							// Show duplicate alert
							showDuplicateAlert(
								appName: duplicate.name ?? duplicate.fileName,
								onContinue: {
									Logger.misc.info("[ShareSheet] 📦 User chose to continue import despite duplicate")
									download.isPreparing = false
									continueImport(tempFileURL: tempFileURL, tempDir: tempDir, download: download, fileManager: fileManager, fileHash: hash, fileName: originalFileName)
								},
								onCancel: {
									Logger.misc.info("[ShareSheet] 🚫 User cancelled duplicate import")
									// Clean up
									try? fileManager.removeItem(at: tempDir)
									DispatchQueue.main.async {
										if let index = downloadManager.getDownloadIndex(by: download.id) {
											downloadManager.downloads.remove(at: index)
										}
									}
								}
							)
						} else {
							Logger.misc.info("[ShareSheet] ✨ No duplicate found, continuing...")
							download.isPreparing = false
							continueImport(tempFileURL: tempFileURL, tempDir: tempDir, download: download, fileManager: fileManager, fileHash: hash, fileName: originalFileName)
						}
					}
				} else {
					Logger.misc.error("[ShareSheet] ❌ Failed to calculate file hash, continuing without duplicate check")
					DispatchQueue.main.async {
						download.isPreparing = false
						continueImport(tempFileURL: tempFileURL, tempDir: tempDir, download: download, fileManager: fileManager, fileHash: nil, fileName: originalFileName)
					}
				}
			}
		} catch {
			// Release security-scoped resource on error
			if didStartAccessing {
				url.stopAccessingSecurityScopedResource()
			}
			
			Logger.misc.error("[ShareSheet] ❌ Failed to copy file: \(error.localizedDescription)")
			DispatchQueue.main.async {
				UIAlertController.showAlertWithOk(
					title: .localized("Error"),
					message: error.localizedDescription
				)
			}
			
			// Clean up on error
			try? fileManager.removeItem(at: tempDir)
		}
	}
	
	/// Continue with the import process
	private static func continueImport(
		tempFileURL: URL,
		tempDir: URL,
		download: Download,
		fileManager: FileManager,
		fileHash: String?,
		fileName: String
	) {
		Logger.misc.info("[ShareSheet] 📦 Calling FR.handlePackageFile...")
		FR.handlePackageFile(tempFileURL, download: download, fileHash: fileHash, fileName: fileName) { error in
			// Clean up temp directory
			try? fileManager.removeItem(at: tempDir)
			
			// Remove download from list (completion handler)
			DispatchQueue.main.async {
				let downloadManager = DownloadManager.shared
				if let index = downloadManager.getDownloadIndex(by: download.id) {
					downloadManager.downloads.remove(at: index)
					Logger.misc.info("[ShareSheet] 🧹 Removed download from tracking list")
				}
			}
			
			if let error = error {
				Logger.misc.error("[ShareSheet] ❌ Import failed with error: \(error.localizedDescription)")
				DispatchQueue.main.async {
					UIAlertController.showAlertWithOk(
						title: .localized("Error"),
						message: error.localizedDescription
					)
				}
			} else {
				Logger.misc.info("[ShareSheet] ✨ Import completed successfully!")
				// Note: Notification to open signing view is sent from AppFileHandler.addToDatabase
			}
		}
	}
	
	/// Show duplicate app alert
	private static func showDuplicateAlert(
		appName: String?,
		onContinue: @escaping () -> Void,
		onCancel: @escaping () -> Void
	) {
		let alert = UIAlertController(
			title: .localized("Duplicate App Detected"),
			message: String(format: .localized("An app with the same content (\"%@\") has already been imported. Do you want to import it again?"), appName ?? .localized("Unknown")),
			preferredStyle: .alert
		)
		
		alert.addAction(UIAlertAction(
			title: .localized("Cancel"),
			style: .cancel
		) { _ in
			onCancel()
		})
		
		alert.addAction(UIAlertAction(
			title: .localized("Continue Import"),
			style: .default
		) { _ in
			onContinue()
		})
		
		UIApplication.topViewController()?.present(alert, animated: true)
	}
	
	static func handlePackageFile(
		_ ipa: URL,
		download: Download? = nil,
		fileHash: String? = nil,
		fileName: String? = nil,
		completion: @escaping (Error?) -> Void
	) {
		Task.detached {
			let handler = AppFileHandler(
				file: ipa,
				download: download,
				fileHash: fileHash,
				fileName: fileName
			)
			
			do {
				try await handler.copy()
				try await handler.extract()
				try await handler.move()
				try await handler.addToDatabase()
				try? await handler.clean()
				await MainActor.run {
					completion(nil)
				}
			} catch {
				try? await handler.clean()
				await MainActor.run {
					completion(error)
				}
			}
		}
	}
	
	static func signPackageFile(
		_ app: AppInfoPresentable,
		using options: Options,
		icon: UIImage?,
		certificate: CertificatePair?,
		completion: @escaping (Error?) -> Void
	) {
		Task.detached {
			let handler = SigningHandler(app: app, options: options)
			handler.appCertificate = certificate
			handler.appIcon = icon
			
			do {
				try await handler.copy()
				try await handler.modify()
				try? await handler.clean()
				await MainActor.run {
					completion(nil)
				}
			} catch {
				try? await handler.clean()
				await MainActor.run {
					completion(error)
				}
			}
		}
	}
	
	static func handleCertificateFiles(
		p12URL: URL,
		provisionURL: URL,
		p12Password: String,
		certificateName: String = "",
		isDefault: Bool = false,
		completion: @escaping (Error?) -> Void
	) {
		Task.detached {
			let handler = CertificateFileHandler(
				key: p12URL,
				provision: provisionURL,
				password: p12Password,
				nickname: certificateName.isEmpty ? nil : certificateName,
				isDefault: isDefault
			)
			
			do {
				try await handler.copy()
				try await handler.addToDatabase()
				await MainActor.run {
					completion(nil)
				}
			} catch {
				await MainActor.run {
					completion(error)
				}
			}
		}
	}
	
	static func checkPasswordForCertificate(
		for key: URL,
		with password: String,
		using provision: URL
	) -> Bool {
		defer {
			password_check_fix_WHAT_THE_FUCK_free(provision.path)
		}
		
		password_check_fix_WHAT_THE_FUCK(provision.path)
		
		if (!p12_password_check(key.path, password)) {
			return false
		}
		
		return true
	}
	
	static func movePairing(_ url: URL) {
		let fileManager = FileManager.default
		let dest = URL.documentsDirectory.appendingPathComponent("pairingFile.plist")
		
		try? fileManager.removeFileIfNeeded(at: dest)
		
		try? fileManager.copyItem(at: url, to: dest)
		
		HeartbeatManager.shared.start(true)
	}
	
	static func downloadSSLCertificates(
		from urlString: String,
		completion: @escaping (Bool) -> Void
	) {
		let generator = UINotificationFeedbackGenerator()
		generator.prepare()
		
		NBFetchService().fetch(from: urlString) { (result: Result<ServerView.ServerPackModel, Error>) in
			switch result {
			case .success(let pack):
				do {
					try FileManager.forceWrite(content: pack.key, to: "server.pem")
					try FileManager.forceWrite(content: pack.cert, to: "server.crt")
					try FileManager.forceWrite(content: pack.info.domains.commonName, to: "commonName.txt")
					generator.notificationOccurred(.success)
					completion(true)
				} catch {
					completion(false)
				}
			case .failure(_):
				completion(false)
			}
		}
	}
	
	static func handleSource(
		_ urlString: String,
		competion: @escaping () -> Void
	) {
		guard let url = URL(string: urlString) else { return }
		
		NBFetchService().fetch<ASRepository>(from: url) { (result: Result<ASRepository, Error>) in
			switch result {
			case .success(let data):
				let id = data.id ?? url.absoluteString
				
				if !Storage.shared.sourceExists(id) {
					Storage.shared.addSource(url, repository: data, id: id) { _ in
						competion()
					}
				} else {
					DispatchQueue.main.async {
						UIAlertController.showAlertWithOk(title: .localized("Error"), message: .localized("Repository already added."))
					}
				}
			case .failure(let error):
				DispatchQueue.main.async {
					UIAlertController.showAlertWithOk(title: .localized("Error"), message: error.localizedDescription)
				}
			}
		}
	}
	
	static func exportCertificateAndOpenUrl(using template: String) {
		// Helper that performs the export for a given certificate
		func performExport(for certificate: CertificatePair) {
			guard
				let certificateKeyFile = Storage.shared.getFile(.certificate, from: certificate),
				let certificateKeyFileData = try? Data(contentsOf: certificateKeyFile)
			else {
				return
			}
			
			let base64encodedCert = certificateKeyFileData.base64EncodedString()
			
			var allowedQueryParamAndKey = NSCharacterSet.urlQueryAllowed
			allowedQueryParamAndKey.remove(charactersIn: ";/?:@&=+$, ")
			
			guard let encodedCert = base64encodedCert.addingPercentEncoding(withAllowedCharacters: allowedQueryParamAndKey) else {
				return
			}
			
			let urlStr = template
				.replacingOccurrences(of: "$(BASE64_CERT)", with: encodedCert)
				.replacingOccurrences(of: "$(PASSWORD)", with: certificate.password ?? "")
			
			guard let callbackUrl = URL(string: urlStr) else {
				return
			}
			
			UIApplication.shared.open(callbackUrl)
		}
		
		let certificates = Storage.shared.getAllCertificates()
		guard !certificates.isEmpty else { return }
		
		DispatchQueue.main.async {
			var selectionActions: [UIAlertAction] = []
			
			for cert in certificates {
				var title: String
				let decoded = Storage.shared.getProvisionFileDecoded(for: cert)
				
				title = cert.nickname ?? decoded?.Name ?? .localized("Unknown")
				
				if let getTaskAllow = decoded?.Entitlements?["get-task-allow"]?.value as? Bool, getTaskAllow == true {
					title = "🐞 \(title)"
				}
				
				let selectAction = UIAlertAction(title: title, style: .default) { _ in
					performExport(for: cert)
				}
				selectionActions.append(selectAction)
			}
			
			UIAlertController.showAlertWithCancel(
				title: .localized("Export Certificate"),
				message: .localized("Do you want to export your certificate to an external app? That app will be able to sign apps using your certificate."),
				style: .alert,
				actions: selectionActions
			)
		}
	}
}
