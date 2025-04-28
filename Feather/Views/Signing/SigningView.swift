//
//  SigningView.swift
//  Feather
//
//  Created by samara on 14.04.2025.
//

import SwiftUI
import PhotosUI
import NimbleViews

// MARK: - View
struct SigningView: View {
	@Environment(\.dismiss) var dismiss
	@StateObject private var _optionsManager = OptionsManager.shared
	
	@State private var _temporaryOptions: Options = OptionsManager.shared.options
	@State private var _temporaryCertificate: Int
	@State private var _isAltPickerPresenting = false
	@State private var _isFilePickerPresenting = false
	@State private var _isImagePickerPresenting = false
	@State private var _isSigning = false
	@State private var _selectedPhoto: PhotosPickerItem? = nil
	@State var appIcon: UIImage?
	
	// MARK: Fetch
	@FetchRequest(
		entity: CertificatePair.entity(),
		sortDescriptors: [NSSortDescriptor(keyPath: \CertificatePair.date, ascending: false)],
		animation: .snappy
	) private var certificates: FetchedResults<CertificatePair>
	
	private func _selectedCert() -> CertificatePair? {
		guard certificates.indices.contains(_temporaryCertificate) else { return nil }
		return certificates[_temporaryCertificate]
	}
	
	var app: AppInfoPresentable
	
	init(app: AppInfoPresentable) {
		self.app = app
		let storedCert = UserDefaults.standard.integer(forKey: "feather.selectedCert")
		__temporaryCertificate = State(initialValue: storedCert)
	}
	
	// MARK: Body
    var body: some View {
		NBNavigationView(app.name ?? "Unknown", displayMode: .inline) {
			Form {
				NBSection("Customization") {
					_customizationOptions(for: app)
				}
				
				NBSection("Signing") {
					_cert()
				}
				
				NBSection("Advanced") {
					_customizationProperties(for: app)
				}
			}
			.safeAreaInset(edge: .bottom) {
				Button() {
					_start()
				} label: {
					_sheetButton("Start Signing")
				}
				.animation(.smooth, value: _isSigning)
				.frame(height: 50)
				.padding()
			}
			.toolbar {
				NBToolbarButton(role: .dismiss)
				
				NBToolbarButton(
					"Reset",
					systemImage: "checkmark",
					style: .text,
					placement: .topBarTrailing
				) {
					_temporaryOptions = OptionsManager.shared.options
					appIcon = nil
				}
			}
			// Image shit
			.sheet(isPresented: $_isAltPickerPresenting) { SigningAlternativeIconView(app: app, appIcon: $appIcon, isModifing: .constant(true)) }
			.sheet(isPresented: $_isFilePickerPresenting) {
				FileImporterRepresentableView(
					allowedContentTypes:  [.image],
					onDocumentsPicked: { urls in
						guard let selectedFileURL = urls.first else { return }
						self.appIcon = UIImage.fromFile(selectedFileURL)?.resizeToSquare()
					}
				)
			}
			.photosPicker(isPresented: $_isImagePickerPresenting, selection: $_selectedPhoto)
			.onChange(of: _selectedPhoto) { newValue in
				guard let newValue else { return }
				
				Task {
					if let data = try? await newValue.loadTransferable(type: Data.self),
					   let image = UIImage(data: data)?.resizeToSquare() {
						appIcon = image
					}
				}
			}
			.disabled(_isSigning)
			.animation(.smooth, value: _isSigning)
		}
		.onAppear {
			// ppq protection
			if
				_optionsManager.options.ppqProtection,
				let identifier = app.identifier,
				let cert = _selectedCert(),
				cert.ppQCheck
			{
				_temporaryOptions.appIdentifier = "\(identifier).\(_optionsManager.options.ppqString)"
			}
			
			if
				let currentBundleId = app.identifier,
				let newBundleId = _temporaryOptions.identifiers[currentBundleId]
			{
				_temporaryOptions.appIdentifier = newBundleId
			}
			
			if
				let currentName = app.name,
				let newName = _temporaryOptions.displayNames[currentName]
			{
				_temporaryOptions.appName = newName
			}
		}
    }
}

// MARK: - Extension: View
extension SigningView {
	@ViewBuilder
	private func _customizationOptions(for app: AppInfoPresentable) -> some View {
		Menu {
			Button("Select Alternative Icon") { _isAltPickerPresenting = true }
			Button("Choose from Files") { _isFilePickerPresenting = true }
			Button("Choose from Photos") { _isImagePickerPresenting = true }
		} label: {
			if let icon = appIcon {
				Image(uiImage: icon)
					.appIconStyle(size: 45, cornerRadius: 12)
			} else {
				FRAppIconView(app: app, size: 45, cornerRadius: 12)
			}
		}
		
		_infoCell("Name", desc: _temporaryOptions.appName ?? app.name) {
			SigningPropertiesView(
				title: "Name",
				initialValue: _temporaryOptions.appName ?? (app.name ?? ""),
				bindingValue: $_temporaryOptions.appName
			)
		}
		_infoCell("Identifier", desc: _temporaryOptions.appIdentifier ?? app.identifier) {
			SigningPropertiesView(
				title: "Identifier",
				initialValue: _temporaryOptions.appIdentifier ?? (app.identifier ?? ""),
				bindingValue: $_temporaryOptions.appIdentifier
			)
		}
		_infoCell("Version", desc: _temporaryOptions.appVersion ?? app.version) {
			SigningPropertiesView(
				title: "Version",
				initialValue: _temporaryOptions.appVersion ?? (app.version ?? ""),
				bindingValue: $_temporaryOptions.appVersion
			)
		}
	}
	
	@ViewBuilder
	private func _customizationProperties(for app: AppInfoPresentable) -> some View {
		DisclosureGroup("Modify") {
			NavigationLink("Existing Dylibs") {
				SigningDylibView(
					app: app,
					options: $_temporaryOptions.optional()
				)
			}
			
			NavigationLink("Frameworks & PlugIns") {
				SigningFrameworksView(
					app: app,
					options: $_temporaryOptions.optional()
				)
			}
			
			NavigationLink("Entitlements") {
				SigningEntitlementsView(
					bindingValue: $_temporaryOptions.appEntitlementsFile
				)
			}
			
			NavigationLink("Tweaks") {
				SigningTweaksView(
					options: $_temporaryOptions
				)
			}
		}
		
		NavigationLink("Properties") {
			Form { SigningOptionsView(
				options: $_temporaryOptions,
				temporaryOptions: _optionsManager.options
			)}
			.navigationTitle("Properties")
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
				CertificatesView(selectedCert: $_temporaryCertificate)
			} label: {
				CertificatesCellView(
					cert: cert,
					shouldDisplayInfo: false,
					isSelectedInfoPresenting: .constant(.none)
				)
			}
		} else {
			Text("No valid certificate selected.")
				.foregroundStyle(Color.disabled())
		}
	}
	
	@ViewBuilder
	private func _sheetButton(_ title: String) -> some View {
		Text(title)
			.frame(maxWidth: .infinity, maxHeight: .infinity)
			.background(Color.accentColor)
			.foregroundColor(.white)
			.clipShape(
				RoundedRectangle(cornerRadius: 12, style: .continuous)
			)
			.bold()
	}
}

// MARK: - Extension: View (import)
extension SigningView {
	private func _start() {
		guard _selectedCert() != nil || _temporaryOptions.doAdhocSigning else {
			UIAlertController.showAlertWithOk(
				title: "No Certificate",
				message: "Please go to settings and import a valid certificate",
				isCancel: true
			)
			return
		}

		let generator = UIImpactFeedbackGenerator(style: .light)
		generator.impactOccurred()
		_isSigning = true
		
		FR.signPackageFile(
			app,
			using: _temporaryOptions,
			icon: appIcon,
			certificate: _selectedCert()
		) { error in
			if let error {
				let ok = UIAlertAction(title: "Dismiss", style: .cancel) { _ in
					dismiss()
				}
				
				UIAlertController.showAlert(
					title: "err",
					message: error.localizedDescription,
					actions: [ok]
				)
			} else {
				dismiss()
			}
		}
	}
}
