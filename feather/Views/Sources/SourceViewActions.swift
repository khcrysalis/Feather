//
//  SourceViewActions.swift
//  feather
//
//  Created by samara on 7/9/24.
//

import Foundation
import UIKit

extension SourcesViewController {
	func makeAddButtonMenu() {
		let pasteMenu = UIMenu(title: "", options: .displayInline, children: [
			UIAction(title: "Import from iCloud Drive", handler: { _ in
				print("Import from iCloud Drive")
			}),
			UIAction(title: "Import from Clipboard", handler: { _ in
				print("Import from Clipboard")
			})
		])

		let configuration = UIMenu(title: "", children: [
			UIAction(title: "Add Batch Sources", handler: { _ in
				print("Add Batch Sources")
			}),
			UIAction(title: "Add Source", handler: { _ in
				self.sourcesAddButtonTapped()
			}),
			pasteMenu
		])
		
		
		addButton.menu = configuration
		addButton.showsMenuAsPrimaryAction = true
	}
	func sourcesAddButtonTapped() {
		let alertController = UIAlertController(title: "Add Source", message: "Add Altstore Repo URL", preferredStyle: .alert)
		
		alertController.addTextField { textField in
			textField.placeholder = "URL"
		}
		
		let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
		alertController.addAction(cancelAction)
		
		let addSourceAction = UIAlertAction(title: "Add Source", style: .default) { _ in
			if let sourceURL = alertController.textFields?.first?.text {
				self.getData(urlString: sourceURL)
			}
		}
		alertController.addAction(addSourceAction)
		self.present(alertController, animated: true, completion: nil)
	}
}
