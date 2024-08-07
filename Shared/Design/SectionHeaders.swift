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
	
	private let actionButton: UIButton = {
		let button = UIButton(type: .system)
		button.titleLabel?.font = .boldSystemFont(ofSize: 14)
		button.setTitleColor(.tintColor, for: .normal)
//		button.backgroundColor = .tintColor.withAlphaComponent(0.2)
		button.backgroundColor = .secondarySystemBackground
		button.translatesAutoresizingMaskIntoConstraints = false
		button.layer.cornerCurve = .continuous
		button.layer.cornerRadius = 13

		// Set contentEdgeInsets to add padding around the title
		button.contentEdgeInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)

		return button
	}()


	
	private let topAnchorConstant: CGFloat
	private let buttonTitle: String?
	private let buttonAction: (() -> Void)?
	
	init(title: String, topAnchorConstant: CGFloat = 10, buttonTitle: String? = nil, buttonAction: (() -> Void)? = nil) {
		self.topAnchorConstant = topAnchorConstant
		self.buttonTitle = buttonTitle
		self.buttonAction = buttonAction
		
		super.init(frame: .zero)
		setupUI()
		self.title = title
		if let title = buttonTitle {
			setupButton(title: title)
		}
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	var title: String {
		get { return titleLabel.text ?? "" }
		set { titleLabel.text = newValue }
	}
	
	private func setupUI() {
		addSubview(titleLabel)
		if buttonTitle != nil { addSubview(actionButton) }
		
		NSLayoutConstraint.activate([
			titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 17),
			titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: topAnchorConstant),
			titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -17),
			titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -topAnchorConstant)
		])
		
		if buttonTitle != nil {
			NSLayoutConstraint.activate([
				actionButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -17),
				actionButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor)
			])
		}
	}
	
	private func setupButton(title: String) {
		actionButton.setTitle(title, for: .normal)
		actionButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
	}
	
	@objc private func buttonTapped() {
		buttonAction?()
	}
	
	override var intrinsicContentSize: CGSize {
		let height = titleLabel.intrinsicContentSize.height + topAnchorConstant * 2
		return CGSize(width: UIView.noIntrinsicMetric, height: height)
	}
}


class InlineButton: UIButton {
	override init(frame: CGRect) {
		super.init(frame: frame)
		let config = UIImage.SymbolConfiguration(paletteColors: [.tintColor, .secondarySystemBackground])
			.applying(UIImage.SymbolConfiguration(pointSize: 23, weight: .unspecified))
		let image = UIImage(systemName: "gearshape.circle.fill")?
			.withRenderingMode(.alwaysTemplate)
			.applyingSymbolConfiguration(config)
		setImage(image, for: .normal)
		contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: -5, right: 0)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

