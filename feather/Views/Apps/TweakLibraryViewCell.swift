//
//  TweakLibraryViewCell.swift
//  feather
//
//  Created by HAHALOSAH on 7/13/24.
//

import Foundation
import UIKit

class TweakLibraryViewCell: UITableViewCell {

    let segmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["Substrate", "Substitute", "Ellekit"])
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(segmentedControl)
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        contentView.addSubview(segmentedControl)
        setupConstraints()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            segmentedControl.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            segmentedControl.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            segmentedControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15)
        ])
    }
}
