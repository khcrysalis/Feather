//
//  FloatingActionButton.swift
//  feather
//
//  Created by samara on 7/4/24.
//

import UIKit
func addAddButtonToView(title: String? = "+",
						image: UIImage? = nil,
						titleColor: UIColor = .white,
						backgroundColor: UIColor = Preferences.appTintColor.uiColor,
						font: UIFont = UIFont.systemFont(ofSize: 20),
						shadowOpacity: Float = 0.3,
						shadowRadius: CGFloat = 11.0,
						shadowOffset: CGSize = CGSize(width: 0, height: 0),
						cornerRadius: CGFloat = 22.5,
						cornerCurve: CALayerCornerCurve = .circular) -> UIButton {
	let addButton = UIButton(type: .system)
	if let title = title {
		addButton.setTitle(title, for: .normal)
		addButton.setTitleColor(titleColor, for: .normal)
		addButton.titleLabel?.font = font
	} else if let image = image {
		addButton.setImage( UIImage(systemName: "folder.fill"), for: .normal)
		addButton.tintColor = .white
		
	}
	addButton.backgroundColor = backgroundColor
	addButton.layer.shadowOpacity = shadowOpacity
	addButton.layer.shadowRadius = shadowRadius
	addButton.layer.shadowOffset = shadowOffset
	addButton.layer.cornerRadius = cornerRadius
	addButton.layer.cornerCurve = cornerCurve
	addButton.translatesAutoresizingMaskIntoConstraints = false
	
	return addButton
}
