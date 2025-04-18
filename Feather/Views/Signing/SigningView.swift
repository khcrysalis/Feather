//
//  SigningView.swift
//  Feather
//
//  Created by samara on 14.04.2025.
//

import SwiftUI

struct SigningView: View {
	@Environment(\.dismiss) var dismiss
	@AppStorage("feather.selectedCert") private var selectedCert: Int = 0
	@StateObject private var optionsManager = OptionsManager.shared
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
	@State private var temporaryOptions: Options = OptionsManager.shared.options
	var app: AppInfoPresentable
	var appCert: CertificatePair?
		
    var body: some View {
		FRNavigationView(app.name ?? "Unknown", displayMode: .inline) {
			Form {
				FRSection("Customization") {
					_customizationOptions(for: app)
				}
				
				FRSection("Signing") {
					_cert(certs: certificates)
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
				}
			}
		}
		.onChange(of: temporaryOptions) { newValue in
			dump(temporaryOptions)
		}
    }
	
	@ViewBuilder
	private func _customizationOptions(for app: AppInfoPresentable) -> some View {
		Button(action: {
			print("icon")
		}, label: {
			_appIconView(for: app)
		})
		
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
	private func _cert(certs: FetchedResults<CertificatePair>) -> some View {
		if certs.indices.contains(selectedCert) {
			CertificatesCellView(cert: certs[selectedCert], isSelected: false)
		} else {
			Text("No valid certificate selected.")
				.foregroundStyle(Color(uiColor: .disabled(.tintColor)))
		}
	}
	
	#warning("move this to its own view with an init")
	@ViewBuilder
	private func _appIconView(for app: AppInfoPresentable) -> some View {
		if
			let iconFilePath = Storage.shared.getAppDirectory(for: app)?.appendingPathComponent(app.icon ?? ""),
			let uiImage = UIImage(contentsOfFile: iconFilePath.path)
		{
			Image(uiImage: uiImage)
				.appIconStyle(size: 45, cornerRadius: 10)
		} else {
			Image(systemName: "app.fill")
				.appIconStyle(size: 45, cornerRadius: 10)
		}
	}
	
	private func _start() {
		Task.detached {
			let handler = await SigningHandler(app: app, options: temporaryOptions)
			
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
