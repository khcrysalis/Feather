//
//  ActivityIndicatorViewCell.swift
//  feather
//
//  Created by HAHALOSAH on 7/17/24.
//

import Foundation
import UIKit

class ActivityIndicatorViewCell: UITableViewCell {

    let activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        return activityIndicator
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(activityIndicator)
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        contentView.addSubview(activityIndicator)
        setupConstraints()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            activityIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            activityIndicator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15)
        ])
    }
}

class ActivityIndicatorButton: UIButton {
	private let activityIndicator: UIActivityIndicatorView = {
		let activityIndicator = UIActivityIndicatorView(style: .medium)
		activityIndicator.color = .white
		activityIndicator.translatesAutoresizingMaskIntoConstraints = false
		return activityIndicator
	}()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		setupButton()
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setupButton()
	}
	
	private func setupButton() {
		setTitle("Start Signing", for: .normal)
		titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
		setTitleColor(.white, for: .normal)
		frame.size = CGSize(width: 100, height: 64)
		
		layer.cornerRadius = 12
		layer.backgroundColor = Preferences.appTintColor.uiColor.cgColor
		layer.cornerCurve = .continuous
		layer.masksToBounds = true
		
		isEnabled = true
	}
	
	func showLoadingIndicator() {
		addSubview(activityIndicator)
		NSLayoutConstraint.activate([
			activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
			activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor)
		])
		
		UIView.transition(with: self, duration: 0.3, options: .transitionCrossDissolve, animations: {
			self.isEnabled = false
			self.setTitle("", for: .normal)
			self.layer.backgroundColor = UIColor.quaternarySystemFill.cgColor
			self.activityIndicator.startAnimating()
		}, completion: nil)
	}
}

