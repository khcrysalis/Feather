//
//  UIKitFileImporter.swift
//  Feather
//
//  Created by samara on 23.04.2025.
//

import SwiftUI
import UniformTypeIdentifiers

struct FileImporterRepresentableView: UIViewControllerRepresentable {
	var allowedContentTypes: [UTType]
	var allowsMultipleSelection: Bool = false
	var onDocumentsPicked: ([URL]) -> Void
	
	func makeCoordinator() -> Coordinator {
		Coordinator(onDocumentsPicked: onDocumentsPicked)
	}
	
	func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
		let picker = UIDocumentPickerViewController(forOpeningContentTypes: allowedContentTypes, asCopy: true)
		picker.delegate = context.coordinator
		picker.allowsMultipleSelection = allowsMultipleSelection
		return picker
	}
	
	func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
	
	class Coordinator: NSObject, UIDocumentPickerDelegate {
		var onDocumentsPicked: ([URL]) -> Void
		
		init(onDocumentsPicked: @escaping ([URL]) -> Void) {
			self.onDocumentsPicked = onDocumentsPicked
		}
		
		func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
			onDocumentsPicked(urls)
		}
		
		func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
			onDocumentsPicked([])
		}
	}
}
