//
//  LibraryInfoView.swift
//  Feather
//
//  Created by samara on 14.04.2025.
//

import SwiftUI
import Zsign

// MARK: - View
struct LibraryInfoView: View {
	@Environment(\.dismiss) var dismiss
	var app: AppInfoPresentable
	
	// MARK: Body
    var body: some View {
		FRNavigationView(app.name ?? "", displayMode: .inline) {
			List {
				Section {} header: {
					FRAppIconView(app: app)
						.frame(maxWidth: .infinity, alignment: .center)
				}
				_infoSection(for: app)
				_bundleSection(for: app)
				_executableSection(for: app)
				
				Section {
					Button("Open in Files") {
						UIApplication.shared.open(
							Storage.shared.getUuidDirectory(for: app)!.toSharedDocumentsURL()!,
							options: [:]
						)
					}
				}
			}
			.toolbar {
				FRToolbarButton(
					"Close",
					systemImage: "xmark",
					placement: .topBarTrailing
				) {
					dismiss()
				}
			}
		}
    }
}

// MARK: - Extension: View
extension LibraryInfoView {
	@ViewBuilder
	private func _infoSection(for app: AppInfoPresentable) -> some View {
		FRSection("Info") {
			if let name = app.name {
				_infoCell("Name", desc: name)
			}
			
			if let ver = app.version {
				_infoCell("Version", desc: ver)
			}
			
			if let id = app.identifier {
				_infoCell("Identifier", desc: id)
			}
			
			if let date = app.date {
				_infoCell("Date Added", desc: date.formatted())
			}
		}
	}
	
	@ViewBuilder
	private func _bundleSection(for app: AppInfoPresentable) -> some View {
		FRSection("Bundle") {
			NavigationLink("Alternative Icons") {
				SigningAlternativeIconView(app: app, appIcon: .constant(nil), isModifing: .constant(false))
			}
			NavigationLink("Frameworks & Plugins") {
				SigningFrameworksView(app: app, options: .constant(nil))
			}
		}
	}
	
	@ViewBuilder
	private func _executableSection(for app: AppInfoPresentable) -> some View {
		FRSection("Executable") {
			NavigationLink("Dylibs") {
				SigningDylibView(app: app, options: .constant(nil))
			}
		}
	}
	
	@ViewBuilder
	private func _infoCell(_ title: String, desc: String) -> some View {
		LabeledContent(title) {
			Text(desc)
		}
	}
}
