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
