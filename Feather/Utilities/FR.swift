//
//  FR.swift
//  Feather
//
//  Created by samara on 22.04.2025.
//

import Foundation.NSURL
import UIKit.UIImage

enum FR {
	static func handlePackageFile(
		_ ipa: URL,
		completion: @escaping (Error?) -> Void
	) {
		Task.detached {
			defer {
				ipa.stopAccessingSecurityScopedResource()
			}
			
			let handler = AppFileHandler(file: ipa)
			
			do {
				try await handler.copy()
				try await handler.extract()
				try await handler.move()
				try await handler.addToDatabase()
				
				await MainActor.run {
					completion(nil)
				}
			} catch {
				try await handler.clean()
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
				try await handler.move()
				try await handler.addToDatabase()
				
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
		certificateName: String,
		completion: @escaping (Error?) -> Void
	) {
		if
			p12URL.startAccessingSecurityScopedResource(),
			provisionURL.startAccessingSecurityScopedResource()
		{
			
			Task.detached {
				defer {
					p12URL.stopAccessingSecurityScopedResource()
					provisionURL.stopAccessingSecurityScopedResource()
				}
				
				let handler = CertificateFileHandler(
					key: p12URL,
					provision: provisionURL,
					password: p12Password,
					nickname: certificateName.isEmpty ? nil : certificateName
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
	}
}
