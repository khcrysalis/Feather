//
//  CertificateViewTableViewCell.swift
//  feather
//
//  Created by samara on 8/8/24.
//

import UIKit

class CertificateViewTableViewCell: UITableViewCell {
	var certs: Certificate?
	
	private let teamNameLabel: UILabel = {
		let label = UILabel()
		label.font = UIFont.boldSystemFont(ofSize: 17)
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	private let expirationDateLabel: UILabel = {
		let label = UILabel()
		label.font = UIFont.systemFont(ofSize: 14)
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	private let pillsStackView: UIStackView = {
		let stackView = UIStackView()
		stackView.axis = .horizontal
		stackView.spacing = 10
		stackView.distribution = .fillProportionally
		stackView.alignment = .leading
		stackView.translatesAutoresizingMaskIntoConstraints = false
		return stackView
	}()
	
	private let roundedBackgroundView: UIView = {
		let view = UIView()
		view.backgroundColor = UIColor.secondarySystemGroupedBackground
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	private let checkmarkImageView: UIImageView = {
		let imageView = UIImageView(image: UIImage(systemName: "checkmark"))
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.isHidden = true
		return imageView
	}()
	
	private let certImageView: UIImageView = {
		let imageView = UIImageView(image: UIImage(named: "certificate"))
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.contentMode = .scaleAspectFit
		return imageView
	}()
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		backgroundColor = .clear
		contentView.addSubview(roundedBackgroundView)
		roundedBackgroundView.addSubview(teamNameLabel)
		roundedBackgroundView.addSubview(expirationDateLabel)
		roundedBackgroundView.addSubview(pillsStackView)
		contentView.addSubview(checkmarkImageView)
		
		NSLayoutConstraint.activate([
			roundedBackgroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
			roundedBackgroundView.topAnchor.constraint(equalTo: contentView.topAnchor),
			roundedBackgroundView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
			roundedBackgroundView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
			
			teamNameLabel.leadingAnchor.constraint(equalTo: roundedBackgroundView.leadingAnchor, constant: 15),
			teamNameLabel.topAnchor.constraint(equalTo: roundedBackgroundView.topAnchor, constant: 10),
			teamNameLabel.trailingAnchor.constraint(equalTo: roundedBackgroundView.trailingAnchor, constant: -15),
			
			expirationDateLabel.leadingAnchor.constraint(equalTo: roundedBackgroundView.leadingAnchor, constant: 15),
			expirationDateLabel.topAnchor.constraint(equalTo: teamNameLabel.bottomAnchor, constant: 5),
			expirationDateLabel.trailingAnchor.constraint(equalTo: roundedBackgroundView.trailingAnchor, constant: -15),
			
			pillsStackView.leadingAnchor.constraint(equalTo: roundedBackgroundView.leadingAnchor, constant: 15),
			pillsStackView.topAnchor.constraint(equalTo: expirationDateLabel.bottomAnchor, constant: 10),
			pillsStackView.trailingAnchor.constraint(equalTo: roundedBackgroundView.trailingAnchor, constant: -15),
			pillsStackView.bottomAnchor.constraint(equalTo: roundedBackgroundView.bottomAnchor, constant: -10),
			
			checkmarkImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
			checkmarkImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
			checkmarkImageView.widthAnchor.constraint(equalToConstant: 20),
			checkmarkImageView.heightAnchor.constraint(equalToConstant: 20)
		])
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func configure(with certificate: Certificate, isSelected: Bool) {
		teamNameLabel.text = certificate.certData?.name
		expirationDateLabel.text = certificate.certData?.appIDName
		certs = certificate
		
		pillsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
		
		if let expirationDate = certificate.certData?.expirationDate {
			let currentDate = Date()
			let calendar = Calendar.current
			let components = calendar.dateComponents([.day], from: currentDate, to: expirationDate)
			
			let daysLeft = components.day ?? 0
			let expirationText = daysLeft < 0 ? "Expired" : "\(daysLeft) days left"
			
			let p1 = PillView(text: expirationText, backgroundColor: daysLeft < 0 ? .systemRed : .systemGray, iconName: daysLeft < 0 ? "xmark" : "timer")
			pillsStackView.addArrangedSubview(p1)
		}
		
		if certificate.certData?.pPQCheck == true {
			let p2 = PillView(text: "PPQCheck", backgroundColor: .systemRed, iconName: "checkmark")
			pillsStackView.addArrangedSubview(p2)
		}
		
		checkmarkImageView.isHidden = !isSelected
	}
}

class CertificateViewAddTableViewCell: UITableViewCell {
	private let titleLabel: UILabel = {
		let label = UILabel()
		label.font = UIFont.boldSystemFont(ofSize: 19)
		label.textColor = .label
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	private let descriptionLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.font = UIFont.systemFont(ofSize: 14)
		label.textColor = .gray
		return label
	}()
	
	private let iconImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.translatesAutoresizingMaskIntoConstraints = false
		return imageView
	}()
	
	private let roundedBackgroundView: UIView = {
		let view = UIView()
		view.layer.cornerRadius = 10
		view.layer.cornerCurve = .continuous
		view.layer.masksToBounds = true
		view.backgroundColor = UIColor.secondarySystemGroupedBackground.withAlphaComponent(0.7)
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	private let borderLayer: CAShapeLayer = {
		let layer = CAShapeLayer()
		layer.strokeColor = UIColor.systemGray.withAlphaComponent(0.4).cgColor
		layer.lineWidth = 1
		layer.fillColor = UIColor.clear.cgColor
		layer.lineDashPattern = [7,7]
		return layer
	}()
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		backgroundColor = .clear
		
		contentView.addSubview(roundedBackgroundView)
		contentView.addSubview(titleLabel)
		contentView.addSubview(descriptionLabel)
		contentView.addSubview(iconImageView)
		
		roundedBackgroundView.layer.addSublayer(borderLayer)
		
		let padding: CGFloat = 16
		
		NSLayoutConstraint.activate([
			roundedBackgroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
			roundedBackgroundView.topAnchor.constraint(equalTo: contentView.topAnchor),
			roundedBackgroundView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
			roundedBackgroundView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
			
			iconImageView.centerXAnchor.constraint(equalTo: roundedBackgroundView.centerXAnchor),
			iconImageView.centerYAnchor.constraint(equalTo: roundedBackgroundView.centerYAnchor),
			iconImageView.widthAnchor.constraint(equalToConstant: 24),
			iconImageView.heightAnchor.constraint(equalToConstant: 24),
			
			titleLabel.centerXAnchor.constraint(equalTo: roundedBackgroundView.centerXAnchor),
			titleLabel.topAnchor.constraint(equalTo: roundedBackgroundView.topAnchor, constant: 30),
			titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: roundedBackgroundView.leadingAnchor, constant: padding),
			titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: roundedBackgroundView.trailingAnchor, constant: -padding),
			
			descriptionLabel.centerXAnchor.constraint(equalTo: roundedBackgroundView.centerXAnchor),
			descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
			descriptionLabel.bottomAnchor.constraint(equalTo: roundedBackgroundView.bottomAnchor, constant: -30),
			descriptionLabel.leadingAnchor.constraint(greaterThanOrEqualTo: roundedBackgroundView.leadingAnchor, constant: padding),
			descriptionLabel.trailingAnchor.constraint(lessThanOrEqualTo: roundedBackgroundView.trailingAnchor, constant: -padding),
		])
	}
	
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		borderLayer.strokeColor = UIColor.systemGray.withAlphaComponent(0.2).cgColor
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		borderLayer.frame = roundedBackgroundView.bounds
		let borderPath = UIBezierPath(roundedRect: roundedBackgroundView.bounds.insetBy(dx: borderLayer.lineWidth / 2, dy: borderLayer.lineWidth / 2), cornerRadius: roundedBackgroundView.layer.cornerRadius)
		borderLayer.path = borderPath.cgPath
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func configure(with title: String?, description: String?) {
		titleLabel.text = title
		descriptionLabel.text = description
	}
	
	func configure(with symbolName: String?) {
		iconImageView.image = UIImage(systemName: symbolName ?? "plus")
	}

}

class PillView: UIView {
	private let iconImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.translatesAutoresizingMaskIntoConstraints = false
		return imageView
	}()
	
	private var label: UILabel = {
		let label = UILabel()
		label.font = UIFont.systemFont(ofSize: 12)
		label.textAlignment = .center
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	private let padding: UIEdgeInsets
	
	init(text: String, backgroundColor: UIColor, iconName: String? = nil, padding: UIEdgeInsets = .init(top: 6, left: 8, bottom: 6, right: 8)) {
		self.padding = padding
		super.init(frame: .zero)
		
		self.backgroundColor = backgroundColor.withAlphaComponent(0.1)
		layer.cornerRadius = 12
		layer.cornerCurve = .continuous
		clipsToBounds = true
		
		// Set up the icon if provided
		if let iconName = iconName {
			iconImageView.image = UIImage(systemName: iconName)
			iconImageView.tintColor = backgroundColor
			addSubview(iconImageView)
		}
		
		addSubview(label)
		label.text = text
		label.textColor = backgroundColor
		
		setupConstraints(iconName: iconName != nil)
	}
	
	private func setupConstraints(iconName: Bool) {
		NSLayoutConstraint.activate([
			iconImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding.left),
			iconImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
			iconImageView.widthAnchor.constraint(equalToConstant: 16),
			iconImageView.heightAnchor.constraint(equalToConstant: 16),
			
			label.topAnchor.constraint(equalTo: topAnchor, constant: padding.top),
			label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -padding.bottom),
			
			label.leadingAnchor.constraint(equalTo: iconName ? iconImageView.trailingAnchor : leadingAnchor, constant: iconName ? 4 : padding.left),
			label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding.right)
		])
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
