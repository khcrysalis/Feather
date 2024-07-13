//
//  RoundedSegmentedControl.swift
//  feather
//
//  Created by samara on 7/13/24.
//

import Foundation
import UIKit

extension UIImage {
	public convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
		let rect = CGRect(origin: .zero, size: size)
		UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
		color.setFill()
		UIRectFill(rect)
		let image = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
	
		guard let cgImage = image?.cgImage else { return nil }
		self.init(cgImage: cgImage)
	}
}

class RoundedSegmentedControl: UISegmentedControl{
	private let segmentInset: CGFloat = 5
	private var segmentImage: UIImage? = UIImage(color: UIColor.secondarySystemGroupedBackground)

	override func layoutSubviews(){
		super.layoutSubviews()
		layer.borderColor = UIColor.clear.cgColor
		layer.cornerRadius = 12
		let foregroundIndex = numberOfSegments
		if subviews.indices.contains(foregroundIndex), let foregroundImageView = subviews[foregroundIndex] as? UIImageView {
			foregroundImageView.bounds = foregroundImageView.bounds.insetBy(dx: segmentInset, dy: segmentInset)
			foregroundImageView.image = segmentImage
			foregroundImageView.layer.removeAnimation(forKey: "SelectionBounds")
			foregroundImageView.layer.masksToBounds = true
			foregroundImageView.layer.cornerRadius = 10
		}
	}
	
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		segmentImage = UIImage(color: UIColor.secondarySystemGroupedBackground)
	}
}
