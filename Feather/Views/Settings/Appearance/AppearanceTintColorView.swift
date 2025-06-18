//
//  AppearanceTintColorView.swift
//  Feather
//
//  Created by samara on 14.06.2025.
//

import SwiftUI

// MARK: - View
struct AppearanceTintColorView: View {
	@AppStorage("Feather.userTintColor") private var selectedColorHex: String = "#B496DC"
	private let tintOptions: [(name: String, hex: String)] = [
		("Default", 		"#B496DC"),
		("Classic", 		"#848ef9"),
		("Berry",   		"#ff7a83"),
		("Cool Blue", 		"#4161F1"),
		("Fuchsia", 		"#FF00FF"),
		("Protokolle", 		"#4CD964"),
		("Aidoku", 			"#FF2D55"),
		("Clock", 			"#FF9500"),
		("Peculiar", 		"#4860e8"),
		("Very Peculiar", 	"#5394F7")
	]
	
	// MARK: Body
	var body: some View {
		ScrollView(.horizontal, showsIndicators: false) {
			LazyHGrid(rows: [GridItem(.fixed(100))], spacing: 12) {
				ForEach(tintOptions, id: \.hex) { option in
					let color = Color(hex: option.hex)
					VStack(spacing: 8) {
						Circle()
							.fill(color)
							.frame(width: 30, height: 30)
							.overlay(
								Circle()
									.strokeBorder(Color.black.opacity(0.3), lineWidth: 2)
							)
						
						Text(option.name)
							.font(.subheadline)
							.foregroundColor(.secondary)
					}
					.frame(width: 120, height: 100)
					.background(Color(uiColor: .secondarySystemGroupedBackground))
					.clipShape(RoundedRectangle(cornerRadius: 10.5, style: .continuous))
					.overlay(
						RoundedRectangle(cornerRadius: 10.5, style: .continuous)
							.strokeBorder(selectedColorHex == option.hex ? color : .clear, lineWidth: 2)
					)
					.onTapGesture {
						selectedColorHex = option.hex
					}
					.accessibilityLabel(Text(option.name))
				}
			}
		}
		.onChange(of: selectedColorHex) { value in
			UIApplication.topViewController()?.view.window?.tintColor = UIColor(Color(hex: value))
		}
	}
}
