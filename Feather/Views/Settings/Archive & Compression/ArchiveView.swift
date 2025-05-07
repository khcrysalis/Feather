//
//  ArchiveView.swift
//  Feather
//
//  Created by samara on 6.05.2025.
//

import SwiftUI
import Zip

struct ArchiveView: View {
	@AppStorage("Feather.compressionLevel") private var _compressionLevel: Int = ZipCompression.DefaultCompression.rawValue
	@AppStorage("Feather.useShareSheetForArchiving") private var _useShareSheet: Bool = false
	
    var body: some View {
		Form {
			Section {
				Picker("Compression Level", systemImage: "archivebox", selection: $_compressionLevel) {
					ForEach(ZipCompression.allCases, id: \.rawValue) { level in
						Text(level.label).tag(level)
					}
				}
			}
			
			Section {
				Toggle("Show Sheet when Exporting", systemImage: "square.and.arrow.up", isOn: $_useShareSheet)
			} footer: {
				Text("Toggling show sheet will present a share sheet after exporting to your files.")
			}
		}
		.navigationTitle("Archive & Compression")
		.navigationBarTitleDisplayMode(.inline)
    }
}
