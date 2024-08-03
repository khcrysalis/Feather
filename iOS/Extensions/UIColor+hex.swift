//
//  UIColor+hex.swift
//  feather
//
//  Created by samara on 5/17/24.
//

import Foundation
import UIKit

extension UIColor {
	convenience init(hex: String) {
		var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
		hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

		var rgb: UInt64 = 0

		Scanner(string: hexSanitized).scanHexInt64(&rgb)

		let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
		let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
		let blue = CGFloat(rgb & 0x0000FF) / 255.0

		self.init(red: red, green: green, blue: blue, alpha: 1.0)
	}
}

extension UIColor {
	static func interpolate(from: UIColor, to: UIColor, with alpha: CGFloat) -> UIColor {
		var fromRed: CGFloat = 0, fromGreen: CGFloat = 0, fromBlue: CGFloat = 0, fromAlpha: CGFloat = 0
		from.getRed(&fromRed, green: &fromGreen, blue: &fromBlue, alpha: &fromAlpha)
		
		var toRed: CGFloat = 0, toGreen: CGFloat = 0, toBlue: CGFloat = 0, toAlpha: CGFloat = 0
		to.getRed(&toRed, green: &toGreen, blue: &toBlue, alpha: &toAlpha)
		
		let interpolatedRed = fromRed + (toRed - fromRed) * alpha
		let interpolatedGreen = fromGreen + (toGreen - fromGreen) * alpha
		let interpolatedBlue = fromBlue + (toBlue - fromBlue) * alpha
		let interpolatedAlpha = fromAlpha + (toAlpha - fromAlpha) * alpha
		
		return UIColor(red: interpolatedRed, green: interpolatedGreen, blue: interpolatedBlue, alpha: interpolatedAlpha)
	}
}
// https://stackoverflow.com/a/69345997
extension UIColor {
	/// Creates a color object that responds to `userInterfaceStyle` trait changes.
	public convenience init(light: UIColor, dark: UIColor) {
	  guard #available(iOS 13.0, *) else { self.init(cgColor: light.cgColor); return }
	  self.init(dynamicProvider: { $0.userInterfaceStyle == .dark ? dark : light })
	}
}
