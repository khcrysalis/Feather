//
//  TweakLibraryViewCell.swift
//  feather
//
//  Created by HAHALOSAH on 7/13/24.
//  Copyright (c) 2024 Samara M (khcrysalis)
//

import Foundation
import UIKit

class TweakLibraryViewCell: UITableViewCell {

	public var segmentedControl: UISegmentedControl = {
		let control = UISegmentedControl()
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

	func configureSegmentedControl(with items: [String], selectedIndex: Int) {
		segmentedControl.removeAllSegments()
		for (index, item) in items.enumerated() {
			segmentedControl.insertSegment(withTitle: item, at: index, animated: false)
		}
		segmentedControl.selectedSegmentIndex = selectedIndex
	}
}

