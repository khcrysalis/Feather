//
//  Date+timeLeft.swift
//  Feather
//
//  Created by samara on 16.04.2025.
//

import Foundation
import SwiftUI

extension Date {
	struct ExpirationInfo {
		let formatted: String
		let color: Color
		let icon: String
	}
	
	func expirationInfo(from now: Date = .now) -> ExpirationInfo {
		let timeLeft = self.timeIntervalSince(now)
		
		guard timeLeft > 0 else {
			return ExpirationInfo(
				formatted: "Expired",
				color: .gray,
				icon: "xmark.octagon"
			)
		}
		
		let daysLeft = Int(timeLeft / 86400)
		let color = Color.expiration(days: daysLeft)
		
		let formatter = Date.expirationFormatter(for: timeLeft)
		let timeString = formatter.string(from: timeLeft) ?? "\(daysLeft) days"
		
		return ExpirationInfo(
			formatted: "\(timeString) left",
			color: color,
			icon: "clock"
		)
	}
	
	private static func expirationFormatter(for interval: TimeInterval) -> DateComponentsFormatter {
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
