//
//  SettingsCreditsTableCell.swift
//  feather
//
//  Created by samara on 7/10/24.
//  Copyright (c) 2024 Samara M (khcrysalis)
//

import UIKit

struct CreditsPerson: Codable {
	let name: String?
	let desc: String?
	let github: String
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
		nameLabel.text = person.name ?? person.github
		roleLabel.text = person.desc ?? person.github

		URLSession.shared.dataTask(with: URL(string: "https://github.com/\(person.github).png")!) { data, _, _ in
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

	private func setupViews() {
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

class BatchPersonCell: UITableViewCell {

	private let textView: UITextView = {
		let textView = UITextView()
		textView.translatesAutoresizingMaskIntoConstraints = false
		textView.isEditable = false
		textView.isScrollEnabled = false
		textView.isUserInteractionEnabled = true
		textView.dataDetectorTypes = .link
		textView.linkTextAttributes = [
			.foregroundColor: UIColor.tintColor
		]
		textView.textContainerInset = .zero
		textView.backgroundColor = .clear
		textView.textContainer.lineFragmentPadding = 0
		textView.textAlignment = .center
		return textView
	}()

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setupViews()
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func configure(with persons: [CreditsPerson]) {
		let attributedText = NSMutableAttributedString()
		
		for (index, person) in persons.enumerated() {
			let name = person.name ?? person.github
			let githubUsername = person.github
			
			let personText = "\(name)"
			let attributedPersonText = NSMutableAttributedString(string: personText, attributes: [
				.font: UIFont.systemFont(ofSize: 15, weight: .semibold)
			])
			
			if let githubURL = URL(string: "https://github.com/\(githubUsername)") {
				let nameRange = (personText as NSString).range(of: name)
				attributedPersonText.addAttribute(.link, value: githubURL, range: nameRange)
			}
			
			if index < persons.count - 1 {
				let commaText = NSAttributedString(string: ", ", attributes: [
					.font: UIFont.systemFont(ofSize: 15, weight: .regular),
					.foregroundColor: UIColor.label
				])
				attributedPersonText.append(commaText)
			}
			
			attributedText.append(attributedPersonText)
		}
		
		textView.attributedText = attributedText
	}

	private func setupViews() {
		contentView.addSubview(textView)
		
		NSLayoutConstraint.activate([
			textView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
			textView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
			textView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
			textView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
		])
	}
}
