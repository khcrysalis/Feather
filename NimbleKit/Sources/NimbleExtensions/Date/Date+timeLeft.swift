//
//  Date+timeLeft.swift
//  Feather
//
//  Created by samara on 16.04.2025.
//

import Foundation
import SwiftUI

extension Date {
	public struct ExpirationInfo {
		public let formatted: String
		public let color: Color
		public let icon: String
	}
	
	/// Gathers data for `ExpirationInfo`
	/// - Parameter now: Date
	/// - Returns: `ExpirationInfo`
	public func expirationInfo(from now: Date = .now) -> ExpirationInfo {
		let timeLeft = self.timeIntervalSince(now)
		
		guard timeLeft > 0 else {
			return ExpirationInfo(
				formatted: .localized("Expired"),
				color: .gray,
				icon: "xmark.octagon"
			)
		}
		
		let daysLeft = Int(timeLeft / 86400)
		let color = Color.expiration(days: daysLeft)
		
		let formatter = Date._expirationFormatter(for: timeLeft)
		let timeString = formatter.string(from: timeLeft) ?? .localized("%lld days", arguments: daysLeft)
		
		return ExpirationInfo(
			formatted: timeString,
			color: color,
			icon: "clock"
		)
	}
	
	private static func _expirationFormatter(for interval: TimeInterval) -> DateComponentsFormatter {
		let formatter = DateComponentsFormatter()
		formatter.allowedUnits = interval < 3600
		? [.minute]
		: interval < 86400
		? [.hour]
		: [.day]
		formatter.unitsStyle = .full
		return formatter
	}
}
