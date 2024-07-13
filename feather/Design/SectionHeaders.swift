//
//  SectionHeader.swift
//  pointercrate
//
//  Created by samara on 3/20/24.
//

import UIKit

class InsetGroupedSectionHeader: UIView {
	private let titleLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 19, weight: .bold)
		label.textColor = UIColor.label
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	private let topAnchorConstant: CGFloat
	
	init(title: String, topAnchorConstant: CGFloat = 7) {
		self.topAnchorConstant = topAnchorConstant
		
		super.init(frame: .zero)
		setupUI()
		self.title = title
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	var title: String {
		get {
			return titleLabel.text ?? ""
		}
		set {
			titleLabel.text = newValue
		}
	}
	
	private func setupUI() {
		addSubview(titleLabel)
		
		NSLayoutConstraint.activate([
			titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 2),
			titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5),
			titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: topAnchorConstant)
		])
	}
}

class GroupedSectionHeader: UIView {
	private let titleLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 19, weight: .bold)
		label.textColor = UIColor.label
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	private let topAnchorConstant: CGFloat
	
	init(title: String, topAnchorConstant: CGFloat = 10) {
		self.topAnchorConstant = topAnchorConstant
		
		super.init(frame: .zero)
		setupUI()
		self.title = title
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	var title: String {
		get {
			return titleLabel.text ?? ""
		}
		set {
			titleLabel.text = newValue
		}
	}
	
	private func setupUI() {
		addSubview(titleLabel)
		
		NSLayoutConstraint.activate([
			titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 17),
			titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: topAnchorConstant),
			titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -17),
			titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -topAnchorConstant)
		])
	}
	
	override var intrinsicContentSize: CGSize {
		let height = titleLabel.intrinsicContentSize.height + topAnchorConstant * 2
		return CGSize(width: UIView.noIntrinsicMetric, height: height)
	}
}

extension UIBarButtonItem {
	static func createBarButtonItem(symbolName: String, paletteColors: [UIColor]? = nil, menu: UIMenu? = nil, target: Any? = nil, action: Selector? = nil, indents: CGFloat? = 0) -> UIBarButtonItem? {
		
		let configuration = UIImage.SymbolConfiguration(pointSize: 22)
		guard let symbolImage = UIImage(systemName: symbolName, withConfiguration: configuration) else { return nil }
		
		var finalImage = symbolImage
		if let paletteColors = paletteColors, !paletteColors.isEmpty {
			if #available(iOS 15.0, *) {
				finalImage = symbolImage.applyingSymbolConfiguration(UIImage.SymbolConfiguration(paletteColors: paletteColors)) ?? symbolImage
			}
		}
		
		var barButtonItem: UIBarButtonItem?
		if let menu = menu {
			barButtonItem = UIBarButtonItem(image: finalImage, menu: menu)
		} else {
			barButtonItem = UIBarButtonItem(image: finalImage, style: .plain, target: target, action: action)
		}
		barButtonItem?.imageInsets = UIEdgeInsets(top: 0, left: indents!, bottom: 0, right: -indents!)
		
		return barButtonItem
	}
}
