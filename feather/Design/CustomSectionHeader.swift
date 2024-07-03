//
//  SectionHeader.swift
//  pointercrate
//
//  Created by samara on 3/20/24.
//

import UIKit

class CustomSectionHeader: UIView {
	private let titleLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 21, weight: .bold)
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
