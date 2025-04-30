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
		presenter.present(controller, animated: true)
	}
}
