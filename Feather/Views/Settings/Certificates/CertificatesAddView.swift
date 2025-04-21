//
//  CertificatesAddView.swift
//  Feather
//
//  Created by samara on 15.04.2025.
//

import SwiftUI
import UniformTypeIdentifiers
import Zsign

// MARK: - View
struct CertificatesAddView: View {
	@Environment(\.managedObjectContext) private var managedObjectContext
	@Environment(\.dismiss) private var dismiss
	
	@State private var p12URL: URL? = nil
	@State private var provisionURL: URL? = nil
	@State private var p12Password: String = ""
	@State private var certificateName: String = ""
	
	@State private var currentImport: ImportType = .none
	@State private var isImporting = false
	@State private var isPasswordAlertPresenting = false
	
	var saveButtonDisabled: Bool {
		p12URL == nil || provisionURL == nil
	}
	
	// MARK: Body
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
				
				Section {
					TextField("Nickname (Optional)", text: $certificateName)
				}
			}
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				FRToolbarButton(role: .cancel)
				
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
				allowedContentTypes: currentImport == .p12 ? [.p12] : [.mobileProvision]
			) { result in
				if case .success(let file) = result {
					if file.startAccessingSecurityScopedResource() {
						if currentImport == .p12 {
							self.p12URL = file
						} else {
							self.provisionURL = file
						}
					}
				}

				currentImport = .none
			}
			.alert(isPresented: $isPasswordAlertPresenting) {
				Alert(title: Text("Bad Password"), message: Text("Please check the password and try again."), dismissButton: .default(Text("OK")))
			}
		}
	}
}

// MARK: - Extension: View
extension CertificatesAddView {
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
}

// MARK: - Extension: View (import)
extension CertificatesAddView {
	private func _checkPassword(for key: URL, with password: String, using provision: URL) -> Bool {
		password_check_fix_WHAT_THE_FUCK(provision.path)
		if (!p12_password_check(key.path, password)) {
			isPasswordAlertPresenting = true
			return false
		}
		
		return true
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
				nickname: certificateName.isEmpty ? nil : certificateName,
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
}

// MARK: - View Enum
enum ImportType {
	case p12, mobileprovision, none
}
