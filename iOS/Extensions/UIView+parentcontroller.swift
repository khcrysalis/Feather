//
//  UIView+parentcontroller.swift
//  feather
//
//  Created by samara on 8/8/24.
//

import Foundation
import UIKit

extension UIView {
	var parentViewController: UIViewController? {
		var parentResponder: UIResponder? = self
		while parentResponder != nil {
			parentResponder = parentResponder?.next
			if let viewController = parentResponder as? UIViewController {
				return viewController
			}
		}
		return nil
	}
}
