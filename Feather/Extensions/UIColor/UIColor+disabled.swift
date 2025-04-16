//
//  UIColor+disabled.swift
//  Feather
//
//  Created by samara on 16.04.2025.
//

import UIKit.UIColor

// https://x.com/SebJVidal/status/1771564199753220609/photo/1
extension UIColor {
	static func disabled(_ color: UIColor) -> UIColor {
		let propertyBase64 = "X2Rpc2FibGVkQ29sb3JGb3JDb2xvcjo="
		guard let data = Data(base64Encoded: propertyBase64),
			  let propertyString = String(data: data, encoding: .utf8) else {
			return .secondaryLabel
		}
		
		let selector = NSSelectorFromString(propertyString)
		let color = perform(selector, with: color).takeUnretainedValue()
		
		return color as? UIColor ?? .secondaryLabel
	}
}
