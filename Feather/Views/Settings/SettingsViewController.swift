//
//  SettingsViewController.swift
//  Feather
//
//  Created by samsam on 5/10/26.
//

import UIKit

class SettingsViewController: ThemedTableViewController {
	override func viewDidLoad() {
		super.viewDidLoad()
		title = "Settings"
	}
}

extension SettingsViewController {
	override func numberOfSections(in tableView: UITableView) -> Int {
		2
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch section {
		case 0: 5
		case 1: 3
		default: 0
		}
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(
			withIdentifier: "Cell",
			for: indexPath
		)
		
		var content = cell.defaultContentConfiguration()
		cell.accessoryType = .disclosureIndicator
		
		switch (indexPath.section, indexPath.row) {
		case (0, 0):
			content.image = SectionIcon(symbolName: "textformat", color: .systemBlue).image()
			content.text = "Appearance"
		case (0, 1):
			content.image = SectionIcon(symbolName: "globe.desk.fill", color: .systemIndigo).image()
			content.text = "Sources"
		case (0, 2):
			content.image = SectionIcon(symbolName: "square.grid.2x2.fill", color: .systemRed).image()
			content.text = "Apps"
		case (0, 3):
			content.image = SectionIcon(symbolName: "arrow.down.circle", color: .systemBlue).image()
			content.text = "Downloads"
		case (0, 4):
			content.image = SectionIcon(symbolName: "gearshape.2.fill", color: .systemGray).image()
			content.text = "Advanced"
		case (1, 0):
			content.image = SectionIcon(symbolName: "checkmark.seal.text.page", color: .systemGreen).image()
			content.text = "Certificates"
		case (1, 1):
			content.image = SectionIcon(symbolName: "pencil.line", color: .systemBlue).image()
			content.text = "Signing"
		case (1, 2):
			content.image = SectionIcon(symbolName: "arrow.down.app", color: .systemIndigo).image()
			content.text = "Installation"
		default: break
		}
		
		cell.contentConfiguration = content
		
		return cell
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		switch (indexPath.section, indexPath.row) {
		case (0, 0):
			navigationController?.pushViewController(AppearanceViewController(), animated: true)
		case (0, 4):
			navigationController?.pushViewController(AdvancedViewController(), animated: true)
		default: break
		}
		
		tableView.deselectRow(at: indexPath, animated: true)
	}
}






//



extension UIColor {
	
	func lighter(_ amount: CGFloat = 0.1) -> UIColor {
		adjust(brightness: 1 + amount)
	}
	
	func darker(_ amount: CGFloat = 0.1) -> UIColor {
		adjust(brightness: 1 - amount)
	}
	
	private func adjust(brightness: CGFloat) -> UIColor {
		var h: CGFloat = 0
		var s: CGFloat = 0
		var b: CGFloat = 0
		var a: CGFloat = 0
		
		guard getHue(&h, saturation: &s, brightness: &b, alpha: &a) else {
			return self
		}
		
		return UIColor(
			hue: h,
			saturation: s,
			brightness: max(min(b * brightness, 1), 0),
			alpha: a
		)
	}
}

extension UIColor {
	func appStoreGradientColors() -> [UIColor] {
		[self.lighter(0.2), self.darker(0.1)]
	}
}

public struct SectionIcon {
	nonisolated(unsafe) private static var cache = [String: UIImage]()
	
	private let symbolName: String
	private let color: UIColor
	
	public init(symbolName: String, color: UIColor) {
		self.symbolName = symbolName
		self.color = color
	}
	
	public func image(
		size: CGSize = CGSize(width: 30, height: 30),
		symbolScale: CGFloat = 0.80
	) -> UIImage? {
		
		let cacheKey = "\(symbolName)-\(color.description)-\(size)"
		
		if let cached = SectionIcon.cache[cacheKey] {
			return cached
		}
		
		let renderer = UIGraphicsImageRenderer(size: size)
		
		let image = renderer.image { context in
			
			let rect = CGRect(origin: .zero, size: size)
			
			var multiplier: CGFloat = 0.2337
			if #available(iOS 26.0, *) {
				multiplier = 0.2677
			}
			
			let radius =
			min(size.width, size.height) * multiplier
			
			let path = UIBezierPath(
				roundedRect: rect,
				cornerRadius: radius
			)
			
			context.cgContext.saveGState()
			path.addClip()
			
			let colors = color.appStoreGradientColors()
				.map(\.cgColor) as CFArray
			
			if let gradient = CGGradient(
				colorsSpace: CGColorSpaceCreateDeviceRGB(),
				colors: colors,
				locations: [0, 1]
			) {
				context.cgContext.drawLinearGradient(
					gradient,
					start: CGPoint(x: size.width / 2, y: 0),
					end: CGPoint(x: size.width / 2, y: size.height),
					options: []
				)
			}
			
			context.cgContext.restoreGState()
			
			UIColor.label
				.withAlphaComponent(0.14)
				.setStroke()
			
			path.lineWidth = 1.0
			path.stroke()
			
			guard let symbol = UIImage(systemName: symbolName) else {
				return
			}
			
			let config = UIImage.SymbolConfiguration(
				hierarchicalColor: .white
			)
			
			let configuredSymbol =
			symbol.applyingSymbolConfiguration(config) ?? symbol
			
			let maxDim =
			min(size.width, size.height) * symbolScale
			
			let aspect =
			configuredSymbol.size.width /
			configuredSymbol.size.height
			
			let drawSize = CGSize(
				width: maxDim * (aspect > 1 ? 1 : aspect),
				height: maxDim * (aspect > 1 ? 1 / aspect : 1)
			)
			
			let drawRect = CGRect(
				x: (size.width - drawSize.width) / 2,
				y: (size.height - drawSize.height) / 2,
				width: drawSize.width,
				height: drawSize.height
			)
			
			configuredSymbol.draw(in: drawRect)
		}
		
		SectionIcon.cache[cacheKey] = image
		
		return image
	}
}
