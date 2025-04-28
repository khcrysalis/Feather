//
//  CertificatesPillView.swift
//  Feather
//
//  Created by samara on 16.04.2025.
//

import SwiftUI

public struct NBPillView: View {
	public var title: String
	public var icon: String
	public var color: Color
	public var index: Int
	public var count: Int
	
	public init(
		title: String,
		icon: String,
		color: Color,
		index: Int,
		count: Int
	) {
		self.title = title
		self.icon = icon
		self.color = color
		self.index = index
		self.count = count
	}
	
	public var body: some View {
		let position = PillPosition.position(for: index, in: count)
		let radii = position.cornerRadii
		
		HStack(spacing: 4) {
			Image(systemName: icon)
				.font(.caption)
				.foregroundStyle(color.opacity(0.9))
			Text(title)
				.font(.caption.bold())
		}
		.frame(maxWidth: .infinity)
		.padding(.vertical, 10)
		.background(
			UnevenRoundedRectangle(
				cornerRadii: .init(
					topLeading: radii.topLeading,
					bottomLeading: radii.bottomLeading,
					bottomTrailing: radii.bottomTrailing,
					topTrailing: radii.topTrailing
				),
				style: .continuous
			)
			.fill(color.opacity(0.15))
		)
	}
	
	public enum PillPosition {
		case single, first, middle, last
		
		static public func position(for index: Int, in count: Int) -> PillPosition {
			switch count {
			case 1: return .single
			case _ where index == 0: return .first
			case _ where index == count - 1: return .last
			default: return .middle
			}
		}
		
		public var cornerRadii: (topLeading: CGFloat, bottomLeading: CGFloat, bottomTrailing: CGFloat, topTrailing: CGFloat) {
			switch self {
			case .single:
				return (10, 10, 10, 10)
			case .first:
				return (10, 10, 5, 5)
			case .middle:
				return (5, 5, 5, 5)
			case .last:
				return (5, 5, 10, 10)
			}
		}
	}
}
