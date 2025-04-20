//
//  SigningOptionsDylibSharedView.swift
//  Feather
//
//  Created by samara on 19.04.2025.
//

import SwiftUI

struct SigningOptionsDylibSharedView: View {
	@State private var dylibs: [String] = []
	@State private var hiddenDylibCount: Int = 0
	
	var app: AppInfoPresentable
	@Binding var options: Options?
	
	var body: some View {
		List {
			Section {
				ForEach(dylibs, id: \.self) { dylib in
					Text(dylib)
						.foregroundColor(options?.disInjectionFiles.contains(dylib) == true ? .red : .primary)
						.swipeActions(edge: .trailing, allowsFullSwipe: false) {
							if options != nil {
								Button("Delete") {
									_addDylib(dylib)
								}
								.tint(.red)
							}
						}
				}
			}
			
			FRSection("Hidden") {
				Text("\(hiddenDylibCount) required system dylibs not shown")
					.font(.footnote)
					.foregroundColor(Color(uiColor: .disabled(.tintColor)))
			}
		}
		.navigationTitle("Dylibs")
		.onAppear(perform: _loadDylibs)
	}
	
	private func _loadDylibs() {
		guard let path = Storage.shared.getAppDirectory(for: app) else { return }
		
		let bundle = Bundle(url: path)
		let execPath = path.appendingPathComponent(bundle?.exec ?? "").relativePath
		
		let allDylibs = Zsign.listDylibs(appExecutable: execPath).map { $0 as String }
		
		dylibs = allDylibs.filter { $0.hasPrefix("@rpath") || $0.hasPrefix("@executable_path") }
		hiddenDylibCount = allDylibs.count - dylibs.count
	}
	
	private func _addDylib(_ dylib: String) {
		guard options != nil else { return }
		if !options!.disInjectionFiles.contains(dylib) {
			options!.disInjectionFiles.append(dylib)
		}
	}
}
