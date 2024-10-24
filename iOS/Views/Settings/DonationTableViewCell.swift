//
//  DonationTableViewCell.swift
//  feather
//
//  Created by samara on 8/10/24.
//  Copyright (c) 2024 Samara M (khcrysalis)
//

import Foundation
import UIKit

class DonationTableViewCell: UITableViewCell {
	
	private let heartImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.image = UIImage(systemName: "heart")?.applyingSymbolConfiguration(.init(pointSize: 23, weight: .bold))
		imageView.contentMode = .scaleAspectFit
		imageView.tintColor = UIColor.init(hex: "db8d8e")
		imageView.translatesAutoresizingMaskIntoConstraints = false
		return imageView
	}()
	
	private let donateLabel: UILabel = {
		let label = UILabel()
		label.text = String.localized("DONATION_DONATIONS")
		label.font = .systemFont(ofSize: 26, weight: .bold)
		label.textColor = .label
		label.textAlignment = .center
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	private let donateButton: UIButton = {
		let button = UIButton(type: .system)
		button.setTitle(String.localized("DONATION_TITLE"), for: .normal)
		button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
		button.backgroundColor = .tintColor.withAlphaComponent(0.9)
		button.setTitleColor(.white, for: .normal)
		button.layer.cornerRadius = 12
		button.layer.cornerCurve = .continuous
		button.clipsToBounds = true
		button.translatesAutoresizingMaskIntoConstraints = false
		return button
	}()
	
	private let stackView: UIStackView = {
		let stackView = UIStackView()
		stackView.axis = .vertical
		stackView.spacing = 12
		stackView.translatesAutoresizingMaskIntoConstraints = false
		return stackView
	}()
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setupViews()
		configureStackViewItems()
		donateButton.addTarget(self, action: #selector(openDonations), for: .touchUpInside) // Correct target for button
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private func setupViews() {
		contentView.addSubview(heartImageView)
		contentView.addSubview(donateLabel)
		contentView.addSubview(donateButton)
		contentView.addSubview(stackView)
		
		NSLayoutConstraint.activate([
			heartImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 14),
			heartImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
			heartImageView.widthAnchor.constraint(equalToConstant: 50),
			heartImageView.heightAnchor.constraint(equalToConstant: 50),
			
			donateLabel.topAnchor.constraint(equalTo: heartImageView.bottomAnchor, constant: 4),
			donateLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
			donateLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.8),
			donateLabel.heightAnchor.constraint(equalToConstant: 40),
			
			donateButton.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 16),
			donateButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
			donateButton.widthAnchor.constraint(equalTo: contentView.widthAnchor, constant: -32),
			donateButton.heightAnchor.constraint(equalToConstant: 45),
			donateButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
			
			stackView.topAnchor.constraint(equalTo: donateLabel.bottomAnchor, constant: 16),
			stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
			stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
		])
	}
	
	@objc func openDonations() {
		guard let url = URL(string: "https://github.com/sponsors/khcrysalis") else {
			Debug.shared.log(message: "Invalid URL")
			return
		}
		UIApplication.shared.open(url, options: [:], completionHandler: nil)
	}
	
	private func configureStackViewItems() {
		let item2 = DonationItemView(
			icon: UIImage(systemName: "lock.fill"),
			title: String.localized("DONATION_CELL_1_TITLE"),
			description: String.localized("DONATION_CELL_1_DESCRIPTION")
		)
		let item3 = DonationItemView(
			icon: UIImage(systemName: "heart.fill"),
			title: String.localized("DONATION_CELL_2_TITLE"),
			description: String.localized("DONATION_CELL_2_DESCRIPTION")
		)
		let item4 = DonationItemView(
			icon: UIImage(systemName: "heart.text.square.fill"),
			title: "Remove This Alert",
			description: "Remove annoying alerts like these after getting beta access!"
		)
		
		stackView.addArrangedSubview(item2)
		stackView.addArrangedSubview(item4)
		stackView.addArrangedSubview(item3)
	}
}


class DonationItemView: UIView {
	private let iconImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.contentMode = .scaleAspectFit
		imageView.translatesAutoresizingMaskIntoConstraints = false
		return imageView
	}()
	
	private let titleLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 16, weight: .bold)
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	private let descriptionLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 14, weight: .regular)
		label.textColor = .secondaryLabel
		label.translatesAutoresizingMaskIntoConstraints = false
		label.numberOfLines = 0
		return label
	}()
	
	init(icon: UIImage?, title: String, description: String) {
		super.init(frame: .zero)
		setupViews()
		iconImageView.image = icon
		titleLabel.text = title
		descriptionLabel.text = description
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private func setupViews() {
		addSubview(iconImageView)
		addSubview(titleLabel)
		addSubview(descriptionLabel)
		
		NSLayoutConstraint.activate([
			iconImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
			iconImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
			iconImageView.widthAnchor.constraint(equalToConstant: 30),
			iconImageView.heightAnchor.constraint(equalToConstant: 30),
			
			titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 8),
			titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
			titleLabel.topAnchor.constraint(equalTo: topAnchor),
			
			descriptionLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 8),
			descriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
			descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
			descriptionLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
		])
	}
}
