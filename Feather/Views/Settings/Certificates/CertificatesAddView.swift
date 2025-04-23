//
//  CertificatesAddView.swift
//  Feather
//
//  Created by samara on 15.04.2025.
//

import SwiftUI
import UniformTypeIdentifiers

// MARK: - View
struct CertificatesAddView: View {
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
					{ currentImport == .p12 ? (self.p12URL = file) : (self.provisionURL = file) }()
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
		.foregroundColor(file == nil ? .accentColor : .disabled(.accentColor))
		.disabled(file != nil)
		.animation(.easeInOut(duration: 0.3), value: file != nil)
		.contentTransition(.opacity)
	}
}

// MARK: - Extension: View (import)
extension CertificatesAddView {
	private func _saveCertificate() {
		guard
			let p12URL = p12URL,
			let provisionURL = provisionURL,
			FR.checkPasswordForCertificate(for: p12URL, with: p12Password, using: provisionURL)
		else {
			isPasswordAlertPresenting = true
			return
		}
		
		FR.handleCertificateFiles(
			p12URL: p12URL,
			provisionURL: provisionURL,
			p12Password: p12Password,
			certificateName: certificateName
		) { _ in
			dismiss()
		}
	}
}

// MARK: - View Enum
enum ImportType {
	case p12, mobileprovision, none
}
