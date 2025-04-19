//
//  CertificatesAddView.swift
//  Feather
//
//  Created by samara on 15.04.2025.
//

import SwiftUI
import UniformTypeIdentifiers
import Zsign

struct CertificatesAddView: View {
	@Environment(\.managedObjectContext) private var managedObjectContext
	@Environment(\.dismiss) private var dismiss
	@State private var p12URL: URL? = nil
	@State private var provisionURL: URL? = nil
	@State private var p12Password: String = ""
	@State private var currentImport: ImportType = .none
	@State private var isImporting = false
	@State private var isPasswordAlertPresenting = false
	
	var saveButtonDisabled: Bool {
		p12URL == nil || provisionURL == nil
	}
	
	var body: some View {
		FRNavigationView("New Certificate") {
			Form {
				FRSection("Files") {
					_importButton("Import Certificate File", type: .p12, file: p12URL)
					_importButton("Import Provisioning File", type: .mobileprovision, file: provisionURL)
				}
				FRSection("Password") {
					SecureField("Enter Password", text: $p12Password)
				} footer: {
					Text("Enter the password associated with the private key. Leave it blank if theres no password required.")
				}
			}
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				FRToolbarButton(
					"Cancel",
					systemImage: "xmark",
					style: .text,
					placement: .cancellationAction
				) {
					dismiss()
				}
				
				FRToolbarButton(
					"Save",
					systemImage: "checkmark",
					style: .text,
					placement: .confirmationAction,
					isDisabled: saveButtonDisabled
				) {
					_saveCertificate()
				}
			}
			.fileImporter(
				isPresented: $isImporting,
				allowedContentTypes: currentImport == .p12 ? [.p12] : [.mobileProvision],
				allowsMultipleSelection: false
			) { result in
				_handleFileImport(result) { url in
					if currentImport == .p12 {
						self.p12URL = url
					} else {
						self.provisionURL = url
					}
				}
				currentImport = .none
			}
			.alert(isPresented: $isPasswordAlertPresenting) {
				Alert(title: Text("Bad Password"), message: Text("Please check the password and try again."), dismissButton: .default(Text("OK")))
			}
		}
	}
	
	@ViewBuilder
	private func _importButton(_ title: String, type: ImportType, file: URL?) -> some View {
		Button(title) {
			currentImport = type
			isImporting = true
		}
		.foregroundColor(file == nil ? .accentColor : Color(uiColor: .disabled(.tintColor)))
		.disabled(file != nil)
		.animation(.easeInOut(duration: 0.3), value: file != nil)
		.contentTransition(.opacity)
	}
	
	private func _handleFileImport(_ result: Result<[URL], Error>, completion: @escaping (URL) -> Void) {
		do {
			let selectedFiles = try result.get()
			if let selectedFile = selectedFiles.first {
				guard selectedFile.startAccessingSecurityScopedResource() else {
					print("Failed to access the file")
					return
				}
				
				print(selectedFile)
				
				completion(selectedFile)
			}
		} catch {
			print("Error selecting file: \(error.localizedDescription)")
		}
	}
	
	private func _saveCertificate() {
		guard
			let p12URL = p12URL,
			let provisionURL = provisionURL,
			_checkPassword(for: p12URL, with: p12Password, using: provisionURL)
		else {
			return
		}
		
		let ppq = CertificateReader(provisionURL).decoded?.PPQCheck ?? false
		
		Task.detached {
			defer {
				p12URL.stopAccessingSecurityScopedResource()
				provisionURL.stopAccessingSecurityScopedResource()
			}
			
			let handler = await CertificateFileHandler(
				key: p12URL,
				provision: provisionURL,
				password: p12Password,
				ppq: ppq
			)
			
			do {
				try await handler.copy()
				try await handler.addToDatabase()
			} catch {
				print(error)
			}

			await dismiss()
		}
	}
	
	private func _checkPassword(for key: URL, with password: String, using provision: URL) -> Bool {
		password_check_fix_WHAT_THE_FUCK(provision.path)
		if (!p12_password_check(key.path, password)) {
			isPasswordAlertPresenting = true
			return false
		}
		
		return true
	}
}

enum ImportType {
	case p12, mobileprovision, none
}
