//
//  UlActivityViewController+Present.swift
//  NimbleKit
//
//  Created by samara on 30.04.2025.
//

import UIKit.UIActivityViewController

extension UIActivityViewController {
	static public func show(
		_ presenter: UIViewController = UIApplication.topViewController()!,
		activityItems: [Any],
		applicationActivities: [UIActivity]? = nil
	) {
		let controller = Self(
			activityItems: activityItems,
			applicationActivities: applicationActivities
		)
		
		if let popover = controller.popoverPresentationController {
			popover.sourceView = presenter.view
			popover.sourceRect = CGRect(
				x: presenter.view.bounds.midX,
				y: presenter.view.bounds.midY,
				width: 0,
				height: 0
			)
			popover.permittedArrowDirections = []
		}
		
		presenter.present(controller, animated: true)
	}
}
