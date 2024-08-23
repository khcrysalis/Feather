//
//  SettingsHeaderTableViewCell.swift
//  feather
//
//  Created by samara on 8/10/24.
//  Copyright (c) 2024 Samara M (khcrysalis)
//

import Foundation
import UIKit
class HeaderTableViewCell: UITableViewCell {
	let titleLabel = UILabel()
	let versionLabel = UILabel()

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setupViews()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setupViews()
	}

	private func setupViews() {
		contentView.addSubview(titleLabel)
		contentView.addSubview(versionLabel)

		titleLabel.translatesAutoresizingMaskIntoConstraints = false
		versionLabel.translatesAutoresizingMaskIntoConstraints = false
		
		titleLabel.font = UIFont.boldSystemFont(ofSize: 22)
		titleLabel.textColor = UIColor.label

		versionLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
		versionLabel.textColor = UIColor.secondaryLabel

		NSLayoutConstraint.activate([
			titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
			titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 26),
			titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: 16),
			titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -16),

			versionLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
			versionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
			versionLabel.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: 16),
			versionLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -16),
			versionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
		])
	}

	func configure(withTitle title: String, versionString: String) {
		titleLabel.text = title.capitalized
		versionLabel.text = versionString
	}
}
