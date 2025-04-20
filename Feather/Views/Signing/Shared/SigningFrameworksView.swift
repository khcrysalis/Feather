//
//  SigningFrameworksView.swift
//  Feather
//
//  Created by samara on 20.04.2025.
//

import SwiftUI

struct SigningFrameworksView: View {
	var app: AppInfoPresentable
	@Binding var options: Options?
	
	@State private var frameworks: [String] = []
	@State private var plugins: [String] = []
	
	private let _frameworksPath = "Frameworks"
	private let _pluginsPath = "PlugIns"
	
	var body: some View {
		List {
			if !frameworks.isEmpty {
				FRSection(_frameworksPath) {
					ForEach(frameworks, id: \.self) { framework in
						SigningToggleCellView(
							title: "\(self._frameworksPath)/\(framework)",
							options: $options,
							arrayKeyPath: \.removeFiles
						)
					}
				}
			}
			
			if !plugins.isEmpty {
				FRSection(_pluginsPath) {
					ForEach(plugins, id: \.self) { plugin in
						SigningToggleCellView(
							title: "\(self._pluginsPath)/\(plugin)",
							options: $options,
							arrayKeyPath: \.removeFiles
						)
					}
				}
			}
		}
		.disabled(options == nil)
		.navigationTitle("Frameworks & PlugIns")
		.onAppear(perform: _listFrameworksAndPlugins)
	}
	
	private func _listFrameworksAndPlugins() {
		guard let path = Storage.shared.getAppDirectory(for: app) else { return }
		
		frameworks = _listFiles(at: path.appendingPathComponent(_frameworksPath))
		plugins = _listFiles(at: path.appendingPathComponent(_pluginsPath))
	}
	
	private func _listFiles(at path: URL) -> [String] {
		(try? FileManager.default.contentsOfDirectory(atPath: path.path)) ?? []
	}
}
