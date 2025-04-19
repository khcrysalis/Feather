//
//  SigningView.swift
//  Feather
//
//  Created by samara on 14.04.2025.
//

import SwiftUI
import PhotosUI

struct SigningView: View {
	@Environment(\.dismiss) var dismiss
	@StateObject private var optionsManager = OptionsManager.shared
	@State private var temporaryOptions: Options = OptionsManager.shared.options
	@State private var temporaryCertificate: Int
	@State private var isAltPickerPresented = false
	@State private var isFilePickerPresented = false
	@State private var isImagePickerPresented = false
	@State private var selectedPhoto: PhotosPickerItem? = nil
	//
	//
	//
	@FetchRequest(
		entity: CertificatePair.entity(),
		sortDescriptors: [NSSortDescriptor(keyPath: \CertificatePair.date, ascending: false)],
		animation: .snappy
	) private var certificates: FetchedResults<CertificatePair>
	//
	//
	//
	var app: AppInfoPresentable
	@State var appCert: CertificatePair?
	@State var appIcon: UIImage?
	
	init(app: AppInfoPresentable) {
		self.app = app
		let storedCert = UserDefaults.standard.integer(forKey: "feather.selectedCert")
		_temporaryCertificate = State(initialValue: storedCert)
	}
		
    var body: some View {
		FRNavigationView(app.name ?? "Unknown", displayMode: .inline) {
			Form {
				FRSection("Customization") {
					_customizationOptions(for: app)
				}
				
				FRSection("Signing") {
					_cert()
				}
				
				FRSection("Advanced") {
					NavigationLink("Properties") {
						Form { SigningOptionsSharedView(
							options: $temporaryOptions,
							temporaryOptions: optionsManager.options
						)}
						.navigationTitle("Properties")
					}
				}
			}
			.safeAreaInset(edge: .bottom) {
				FRSheetButton("Start Signing") {
					_start()
				}
				.frame(height: 50)
				.padding()
			}
			.toolbar {
				FRToolbarButton(
					"Dismiss",
					systemImage: "chevron.left",
					placement: .topBarLeading
				) {
					dismiss()
				}
				
				FRToolbarButton(
					"Reset",
					systemImage: "checkmark",
					style: .text,
					placement: .topBarTrailing
				) {
					temporaryOptions = OptionsManager.shared.options
					appIcon = nil
				}
			}
			// Image shit
			.sheet(isPresented: $isAltPickerPresented) { SigningAppAlternativeIconView(app: app, appIcon: $appIcon) }
			.fileImporter(isPresented: $isFilePickerPresented, allowedContentTypes: [.image]) { result in
				if case .success(let url) = result {
					self.appIcon = UIImage.fromFile(url)?.resizeToSquare()
				}
			}
			.photosPicker(isPresented: $isImagePickerPresented, selection: $selectedPhoto)
			.onChange(of: selectedPhoto) { newValue in
				guard let newValue else { return }
				
				Task {
					if let data = try? await newValue.loadTransferable(type: Data.self),
					   let image = UIImage(data: data)?.resizeToSquare() {
						appIcon = image
					}
				}
			}
		}
    }
	
	@ViewBuilder
	private func _customizationOptions(for app: AppInfoPresentable) -> some View {
		Menu {
			Button("Select Alternative Icon") { isAltPickerPresented = true }
			Button("Choose from Files") { isFilePickerPresented = true }
			Button("Choose from Photos") { isImagePickerPresented = true }
		} label: {
			if let icon = appIcon {
				Image(uiImage: icon)
					.appIconStyle(size: 45, cornerRadius: 12)
			} else {
				FRAppIconView(app: app, size: 45, cornerRadius: 12)
			}
		}
		
		_infoCell("Name", desc: temporaryOptions.appName ?? app.name) {
			SigningAppPropertiesView(
				title: "Name",
				initialValue: temporaryOptions.appName ?? (app.name ?? ""),
				bindingValue: $temporaryOptions.appName
			)
		}
		_infoCell("Identifier", desc: app.identifier) {
			SigningAppPropertiesView(
				title: "Identifier",
				initialValue: temporaryOptions.appIdentifier ?? (app.identifier ?? ""),
				bindingValue: $temporaryOptions.appIdentifier
			)
		}
		_infoCell("Version", desc: app.version) {
			SigningAppPropertiesView(
				title: "Version",
				initialValue: temporaryOptions.appVersion ?? (app.version ?? ""),
				bindingValue: $temporaryOptions.appVersion
			)
		}
	}
	
	@ViewBuilder
	private func _infoCell<V: View>(_ title: String, desc: String?, @ViewBuilder destination: () -> V) -> some View {
		NavigationLink {
			destination()
		} label: {
			LabeledContent(title) {
				Text(desc ?? "Unknown")
			}
		}
	}
	
	@ViewBuilder
	private func _cert() -> some View {
		if let cert = _selectedCert() {
			NavigationLink {
				CertificatesView(selectedCert: $temporaryCertificate)
			} label: {
				CertificatesCellView(cert: cert, isSelected: false)
			}
		} else {
			Text("No valid certificate selected.")
				.foregroundStyle(Color(uiColor: .disabled(.tintColor)))
		}
	}
	
	private func _selectedCert() -> CertificatePair? {
		guard certificates.indices.contains(temporaryCertificate) else { return nil }
		return certificates[temporaryCertificate]
	}
	
	private func _start() {
		#if !DEBUG
		guard _selectedCert() != nil || temporaryOptions.doAdhocSigning else {
			print("somethings not right")
			return
		}
		#endif
		
		Task.detached {
			let handler = await SigningHandler(app: app, options: temporaryOptions)
			handler.appCertificate = await _selectedCert()
			handler.appIcon = await appIcon
			
			do {
				try await handler.copy()
				try await handler.modify()
				try await handler.move()
				try await handler.addToDatabase()
			} catch {
				print(error)
			}
		}
	}
}
