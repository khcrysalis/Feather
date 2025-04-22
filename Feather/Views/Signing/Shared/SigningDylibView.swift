//
//  SigningOptionsDylibSharedView.swift
//  Feather
//
//  Created by samara on 19.04.2025.
//

import SwiftUI

// MARK: - View
struct SigningDylibView: View {
	@State private var dylibs: [String] = []
	@State private var hiddenDylibCount: Int = 0
	
	var app: AppInfoPresentable
	@Binding var options: Options?
	
	var body: some View {
		List {
			Section {
				ForEach(dylibs, id: \.self) { dylib in
					SigningToggleCellView(
						title: dylib,
						options: $options,
						arrayKeyPath: \.disInjectionFiles
					)
				}
			}
			
			FRSection("Hidden") {
				Text("\(hiddenDylibCount) required system dylibs not shown")
					.font(.footnote)
					.foregroundColor(.disabled(.accentColor))
			}
		}
		.disabled(options == nil)
		.navigationTitle("Dylibs")
		.onAppear(perform: _loadDylibs)
	}
}

// MARK: - Extension: View
extension SigningDylibView {
	private func _loadDylibs() {
		guard let path = Storage.shared.getAppDirectory(for: app) else { return }
		
		let bundle = Bundle(url: path)
		let execPath = path.appendingPathComponent(bundle?.exec ?? "").relativePath
		
		let allDylibs = Zsign.listDylibs(appExecutable: execPath).map { $0 as String }
		
		dylibs = allDylibs.filter { $0.hasPrefix("@rpath") || $0.hasPrefix("@executable_path") }
		hiddenDylibCount = allDylibs.count - dylibs.count
	}
}
