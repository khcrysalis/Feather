//
//  SourceAppTableViewCell.swift
//  feather
//
//  Created by samara on 5/22/24.
//

import Foundation
import UIKit

class AppTableViewCell: UITableViewCell {
	let nameLabel: UILabel = {
		let label = UILabel()
		label.font = UIFont.boldSystemFont(ofSize: 17)
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	let versionLabel: UILabel = {
		let label = UILabel()
		label.font = UIFont.boldSystemFont(ofSize: 13)
		label.textColor = .secondaryLabel
		label.numberOfLines = 0
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	let detailLabel: UILabel = {
		let label = UILabel()
		label.font = UIFont.systemFont(ofSize: 11)
		label.textColor = .secondaryLabel
		label.numberOfLines = 0
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setupViews()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private func setupViews() {
		backgroundColor = UIColor(named: "Background")
		contentView.addSubview(nameLabel)
		contentView.addSubview(versionLabel)
		contentView.addSubview(detailLabel)
		NSLayoutConstraint.activate([
			nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 72),
			nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
			
			versionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 72),
			versionLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor),
			versionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
			
			detailLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 72),
			detailLabel.topAnchor.constraint(equalTo: versionLabel.bottomAnchor),
			detailLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
			detailLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
		])
	}
	
	func configure(with app: StoreApps) {
		var name = app.name
		if app.bundleIdentifier!.hasSuffix("Beta") {
			name! += " (Beta)"
		}
		nameLabel.text = name
		var desc = app.developerName ?? "Unknown"
		desc += " • "
		desc += app.version!
		versionLabel.text = desc
		detailLabel.text = app.subtitle ?? "An awesome application!"
	}
}
