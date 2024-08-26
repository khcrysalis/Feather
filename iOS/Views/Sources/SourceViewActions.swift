//
//  SourceViewActions.swift
//  feather
//
//  Created by samara on 7/9/24.
//  Copyright (c) 2024 Samara M (khcrysalis)
//

import Foundation
import UIKit

extension SourcesViewController {

	func sourcesAddButtonTapped() {
		let alertController = UIAlertController(title: String.localized("SOURCES_VIEW_ADD_SOURCES_ALERT_TITLE"), message: String.localized("SOURCES_VIEW_ADD_SOURCES_ALERT_DESCRIPTION"), preferredStyle: .alert)
		
		alertController.addTextField { textField in
			textField.placeholder = "URL"
		}
		
		let cancelAction = UIAlertAction(title: String.localized("CANCEL"), style: .cancel, handler: nil)
		alertController.addAction(cancelAction)
		
		let addSourceAction = UIAlertAction(title: String.localized("SOURCES_VIEW_ADD_SOURCES_ALERT_TITLE"), style: .default) { _ in
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
