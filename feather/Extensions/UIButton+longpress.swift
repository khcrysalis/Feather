//
//  UIButton+longpress.swift
//  feather
//
//  Created by samara on 7/7/24.
//

import Foundation
import UIKit

extension UIButton {
	private struct AssociatedKeys {
		static var longPressGestureRecognizer = "longPressGestureRecognizer"
	}
	
	var longPressGestureRecognizer: UILongPressGestureRecognizer? {
		get {
			return objc_getAssociatedObject(self, &AssociatedKeys.longPressGestureRecognizer) as? UILongPressGestureRecognizer
		}
		set {
			objc_setAssociatedObject(self, &AssociatedKeys.longPressGestureRecognizer, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
		}
	}
}
