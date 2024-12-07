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
			withUnsafePointer(to: AssociatedKeys.longPressGestureRecognizer) {
				return objc_getAssociatedObject(self, $0) as? UILongPressGestureRecognizer
			}
		}
		set {
			withUnsafePointer(to: AssociatedKeys.longPressGestureRecognizer) {
				objc_setAssociatedObject(self, $0, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
			}
		}
	}
}
