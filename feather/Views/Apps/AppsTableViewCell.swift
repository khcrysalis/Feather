//
//  AppsTableViewCell.swift
//  feather
//
//  Created by samara on 7/1/24.
//

import Foundation
import UIKit
import CoreData

class AppsTableViewCell: UITableViewCell {

	let nameLabel: UILabel = {
		let label = UILabel()
		label.font = UIFont.boldSystemFont(ofSize: 17)
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	let versionLabel: UILabel = {
		let label = UILabel()
		label.font = UIFont.systemFont(ofSize: 13)
		label.textColor = .secondaryLabel
		label.numberOfLines = 0
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	let detailLabel: UILabel = {
		let label = UILabel()
		label.font = UIFont.systemFont(ofSize: 11)
		label.textColor = .secondaryLabel
		label.numberOfLines = 1
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
		imageView?.translatesAutoresizingMaskIntoConstraints = true

		NSLayoutConstraint.activate([
			nameLabel.leadingAnchor.constraint(equalTo: imageView!.trailingAnchor, constant: 15),
			nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
			
			versionLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
			versionLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
			versionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
			
			detailLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
			detailLabel.topAnchor.constraint(equalTo: versionLabel.bottomAnchor, constant: 4),
			detailLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
			detailLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
		])
	}


	override func layoutSubviews() {
		super.layoutSubviews()
	}
	
	func configure(with app: NSManagedObject, filePath: URL) {
		
		var appname = ""
		if let name = app.value(forKey: "name") as? String {
			appname += name
			
		}
				
		var desc = ""
		if let version = app.value(forKey: "version") as? String {
			desc += version
		}
		desc += " • "
		if let bundleIdentifier = app.value(forKey: "bundleidentifier") as? String {
			desc += bundleIdentifier
			
			if bundleIdentifier.hasSuffix("Beta") {
				appname += " (Beta)"
			}
			
		}
		
		if FileManager.default.fileExists(atPath: filePath.path) {
			if let uu = app.value(forKey: "uuid") as? String {
				detailLabel.text = uu
			}
		} else {
			detailLabel.text = "File has been deleted."
			detailLabel.textColor = .systemRed
		}
		
		nameLabel.text = appname
		versionLabel.text = desc
	}
}

