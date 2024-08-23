//
//  IconsListTableViewCell.swift
//  feather
//
//  Created by samara on 8/11/24.
//  Copyright (c) 2024 Samara M (khcrysalis)
//

import UIKit

class IconsListTableViewCell: UITableViewCell {

	private let iconView: UIImageView = {
		let imageView = UIImageView()
		imageView.contentMode = .scaleAspectFill
		imageView.clipsToBounds = true
		imageView.layer.cornerRadius = 12
		imageView.layer.cornerCurve = .continuous
		imageView.layer.borderWidth = 1
		imageView.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.3).cgColor
		imageView.translatesAutoresizingMaskIntoConstraints = false
		return imageView
	}()

	private let iconName: UILabel = {
		let label = UILabel()
		label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
		label.textColor = .label
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()

	private let author: UILabel = {
		let label = UILabel()
		label.font = UIFont.systemFont(ofSize: 13, weight: .light)
		label.textColor = .secondaryLabel
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()

	var altIcon: AltIcon? {
		didSet {
			if let altIcon = altIcon {
				iconName.text = altIcon.displayName
				iconView.image = altIcon.image
				author.text = altIcon.author
			}
		}
	}

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setupViews()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private func setupViews() {
		contentView.addSubview(iconView)
		contentView.addSubview(iconName)
		contentView.addSubview(author)
		
		NSLayoutConstraint.activate([
			iconView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 17.5),
			iconView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
			iconView.widthAnchor.constraint(equalToConstant: 52),
			iconView.heightAnchor.constraint(equalToConstant: 52),

			iconName.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 17.5),
			iconName.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -7.5),
			iconName.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: -7.5),

			author.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 17.5),
			author.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -7.5),
			author.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: 10)
		])
	}
}
