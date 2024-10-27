//
//  IconImageViewCell.swift
//  feather
//
//  Created by samara on 8/12/24.
//  Copyright (c) 2024 Samara M (khcrysalis)
//

import Foundation
import UIKit

class IconImageViewCell: UITableViewCell {

	private let iconImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.contentMode = .scaleAspectFit
		imageView.layer.cornerRadius = 10
		imageView.layer.cornerCurve = .continuous
		imageView.layer.borderWidth = 1
		imageView.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.3).cgColor
		imageView.clipsToBounds = true
		return imageView
	}()

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setupImageView()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setupImageView()
	}

	private func setupImageView() {
		contentView.addSubview(iconImageView)
		
		NSLayoutConstraint.activate([
			iconImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
			iconImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
			iconImageView.widthAnchor.constraint(equalToConstant: 45),
			iconImageView.heightAnchor.constraint(equalToConstant: 45),
			iconImageView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -10)
		])
	}


	func configure(with image: UIImage?) {
		iconImageView.image = image
	}
}

