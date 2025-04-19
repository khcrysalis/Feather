//
//  Color+Codable.swift
//  Feather
//
//  Created by Lakhan Lothiyi on 19/04/2025.
//

import SwiftUI

// taken from skykit
// MARK: - Make Color conform to codable
extension Color: Codable {
	public init(hex: String) {
		let rgba = hex.toRGBA()

		self.init(
			.sRGB,
			red: Double(rgba.r),
			green: Double(rgba.g),
			blue: Double(rgba.b),
			opacity: Double(rgba.alpha))
	}

	public init(from decoder: Decoder) throws {
		let container = try decoder.singleValueContainer()
		let hex = try container.decode(String.self)

		self.init(hex: hex)
	}

	public func encode(to encoder: Encoder) throws {
		var container = encoder.singleValueContainer()
		try container.encode(toHex)
	}

	public var toHex: String {
		return toHex()
	}

	public func toHex(alpha: Bool = false) -> String {
		
		// had to use this shim
		let (r, g, b, a) = {
			if #available(iOS 17.0, *) {
				
				let resolved = resolve(in: EnvironmentValues())
				
				let r = resolved.red
				let g = resolved.green
				let b = resolved.blue
				let a = resolved.opacity
				
				return (r, g, b, a)
			} else {
				let (r, g, b, a) = components
				return (
					Float(r),
					Float(g),
					Float(b),
					Float(a)
				)
			}
		}()

		if alpha {
			return String(
				format: "%02lX%02lX%02lX%02lX",
				lroundf(r * 255),
				lroundf(g * 255),
				lroundf(b * 255),
				lroundf(a * 255))
		} else {
			return String(
				format: "%02lX%02lX%02lX",
				lroundf(r * 255),
				lroundf(g * 255),
				lroundf(b * 255))
		}
	}
}

public extension String {
	func toRGBA() -> (r: CGFloat, g: CGFloat, b: CGFloat, alpha: CGFloat) {
		var hexSanitized = self.trimmingCharacters(in: .whitespacesAndNewlines)
		hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

		var rgb: UInt64 = 0

		var r: CGFloat = 0.0
		var g: CGFloat = 0.0
		var b: CGFloat = 0.0
		var a: CGFloat = 1.0

		let length = hexSanitized.count

		Scanner(string: hexSanitized).scanHexInt64(&rgb)

		if length == 6 {
			r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
			g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
			b = CGFloat(rgb & 0x0000FF) / 255.0
		} else if length == 8 {
			r = CGFloat((rgb & 0xFF00_0000) >> 24) / 255.0
			g = CGFloat((rgb & 0x00FF_0000) >> 16) / 255.0
			b = CGFloat((rgb & 0x0000_FF00) >> 8) / 255.0
			a = CGFloat(rgb & 0x0000_00FF) / 255.0
		}

		return (r, g, b, a)
	}
}

extension Color: @retroactive RawRepresentable {
	public var rawValue: String {
		return toHex
	}

	public init?(rawValue: String) {
		self.init(hex: rawValue)
	}
}

// MARK: - Get color values of Color
	// taken from meret
public extension Color {
	var components: (red: CGFloat, green: CGFloat, blue: CGFloat, opacity: CGFloat) {
		
#if canImport(UIKit)
		typealias NativeColor = UIColor
#elseif canImport(AppKit)
		typealias NativeColor = NSColor
#endif
		
		var r: CGFloat = 0
		var g: CGFloat = 0
		var b: CGFloat = 0
		var o: CGFloat = 0
		
		guard NativeColor(self).getRed(&r, green: &g, blue: &b, alpha: &o) else {
			// You can handle the failure here as you want
			return (0, 0, 0, 0)
		}
		
		return (r, g, b, o)
	}
}
