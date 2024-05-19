//
//  File.swift
//  feather
//
//  Created by samara on 5/18/24.
//

import Foundation
import UIKit


class SourcesTableViewCell: UITableViewCell {
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		configureUI()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private func configureUI() {
		backgroundColor = UIColor(named: "Background")
		contentView.layer.cornerRadius = 12
		contentView.layer.masksToBounds = true
	}
}
