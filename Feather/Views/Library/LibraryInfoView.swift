//
//  LibraryInfoView.swift
//  Feather
//
//  Created by samara on 14.04.2025.
//

import SwiftUI
import Zsign

struct LibraryInfoView: View {
	@Environment(\.dismiss) var dismiss
	
	var app: Imported
	
	@State private var dylibs: [String] = []
	
    var body: some View {
		FRNavigationView(app.name ?? "", displayMode: .inline) {
			List {
				Section {} header: {
					_appIconView(for: app)
						.frame(maxWidth: .infinity, alignment: .center)
				}
				_infoSection(for: app)
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
	
	@ViewBuilder
	private func _infoSection(for app: Imported) -> some View {
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
	private func _appIconView(for app: Imported) -> some View {
		if
			let iconFilePath = Storage.shared.getDirectory(for: app)?.appendingPathComponent(app.icon ?? ""),
			let uiImage = UIImage(contentsOfFile: iconFilePath.path)
		{
			Image(uiImage: uiImage)
				.appIconStyle(size: 87, cornerRadius: 20)
		} else {
			Image(systemName: "app.fill")
				.appIconStyle()
		}
	}
	
	@ViewBuilder
	private func _bundleSection(for app: Imported) -> some View {
		FRSection("Bundle") {
		}
	}
	
	@ViewBuilder
	private func _executableSection(for app: Imported) -> some View {
		FRSection("Executable") {
			NavigationLink("Dylibs") {
				List(dylibs, id: \.self) { dylib in
					Text(dylib)
				}
				.navigationTitle("Dylibs")
				.onAppear {
					loadDylibs()
				}
			}
		}
	}
	
	private func loadDylibs() {
		guard let path = Storage.shared.getDirectory(for: app) else {
			return
		}
				
		let bundle = Bundle(url: path)
		let new_path = path.appendingPathComponent(bundle?.exec ?? "").relativePath
		
		if let nsArray = ListDylibs(new_path) {
			dylibs = nsArray
				.map { $0 as String }
				.filter { $0.hasPrefix("@rpath") || $0.hasPrefix("@executable_path") }
		} else {
			print("Failed to load dylibs.")
		}
	}
	
	@ViewBuilder
	private func _infoCell(_ title: String, desc: String) -> some View {
		LabeledContent(title) {
			Text(desc)
		}
	}
}
