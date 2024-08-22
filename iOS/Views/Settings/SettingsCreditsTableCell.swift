//
//  SettingsCreditsTableCell.swift
//  feather
//
//  Created by samara on 7/10/24.
//

import UIKit

class CreditsData {
	static func getCreditsData() -> [CreditsPerson] {
		let a = CreditsPerson(name: "Samara", role: "Developer", pfpURL: URL(string: "https://github.com/khcrysalis.png")!, socialLink: URL(string: "https://github.com/khcrysalis")!)

		let b = CreditsPerson(name: "HHLS", role: "Operations", pfpURL: URL(string: "https://github.com/HAHALOSAH.png")!, socialLink: URL(string: "https://github.com/HAHALOSAH")!)
		
		let c = CreditsPerson(name: "Lakhan Lothiyi", role: "Help w/ Onboarding", pfpURL: URL(string: "https://github.com/llsc12.png")!, socialLink: URL(string: "https://github.com/llsc12")!)

		let d = CreditsPerson(name: "Mineek", role: "Help w/ Tweak Injection", pfpURL: URL(string: "https://github.com/mineek.png")!, socialLink: URL(string: "https://github.com/mineek")!)

		
		return [a, b, c, d]
	}
}

struct CreditsPerson {
	let name: String
	let role: String
	let pfpURL: URL
	let socialLink: URL?
}

class PersonCell: UITableViewCell {
	var personImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.contentMode = .scaleAspectFit
		imageView.layer.cornerRadius = 22.5
		imageView.clipsToBounds = true
		
		return imageView
	}()


	var nameLabel: UILabel = {
		let label = UILabel()
		label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
		label.translatesAutoresizingMaskIntoConstraints = false
		label.numberOfLines = 0
		label.lineBreakMode = .byWordWrapping
		return label
	}()

	var roleLabel: UILabel = {
		let label = UILabel()
		label.font = UIFont.systemFont(ofSize: 14)
		label.translatesAutoresizingMaskIntoConstraints = false
		label.numberOfLines = 0
		label.textColor = .secondaryLabel
		label.lineBreakMode = .byWordWrapping
		return label
	}()

	func configure(with person: CreditsPerson) {
		nameLabel.text = person.name
		roleLabel.text = person.role

		URLSession.shared.dataTask(with: person.pfpURL) { data, _, _ in
			if let data = data, let uiImage = UIImage(data: data) {
				DispatchQueue.main.async {
					self.personImageView.image = uiImage
				}
			}
		}
		.resume()
	}

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setupViews()
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func setupViews() {
		contentView.addSubview(personImageView)
		contentView.addSubview(nameLabel)
		contentView.addSubview(roleLabel)

		NSLayoutConstraint.activate([
			personImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
			personImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
			personImageView.widthAnchor.constraint(equalToConstant: 45),
			personImageView.heightAnchor.constraint(equalToConstant: 45),

			nameLabel.leadingAnchor.constraint(equalTo: personImageView.trailingAnchor, constant: 16),
			nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
			nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

			roleLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
			roleLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
			roleLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
			roleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
		])
	}
}
