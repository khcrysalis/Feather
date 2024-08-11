//
//  SourceViewActions.swift
//  feather
//
//  Created by samara on 7/9/24.
//

import Foundation
import UIKit

extension SourcesViewController {

	func sourcesAddButtonTapped() {
		let alertController = UIAlertController(title: "Add Source", message: "Add Altstore Repo URL", preferredStyle: .alert)
		
		alertController.addTextField { textField in
			textField.placeholder = "URL"
		}
		
		let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
		alertController.addAction(cancelAction)
		
		let addSourceAction = UIAlertAction(title: "Add Source", style: .default) { _ in
			if let sourceURL = alertController.textFields?.first?.text {
				CoreDataManager.shared.getSourceData(urlString: sourceURL) { error in
					if let error = error {
						Debug.shared.log(message: "SourcesViewController.sourcesAddButtonTapped: \(error)", type: .critical)
					} else {
						NotificationCenter.default.post(name: Notification.Name("sfetch"), object: nil)
					}
				}
			}
		}
		alertController.addAction(addSourceAction)
		self.present(alertController, animated: true, completion: nil)
	}
}
