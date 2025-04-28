//
//  UIApplication+topController.swift
//  Loader
//
//  Created by samara on 18.03.2025.
//

import UIKit.UIApplication

extension UIApplication {
	/// This belongs to https://stackoverflow.com/a/30858591
	public class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
		if let navigationController = controller as? UINavigationController {
			return topViewController(controller: navigationController.visibleViewController)
		}
		if let tabController = controller as? UITabBarController {
			if let selected = tabController.selectedViewController {
				return topViewController(controller: selected)
			}
		}
		if let presented = controller?.presentedViewController {
			return topViewController(controller: presented)
		}
		return controller
	}
}
