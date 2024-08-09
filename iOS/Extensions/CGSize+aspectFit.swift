//
//  CGSize+aspectFit.swift
//  feather
//
//  Created by samara on 8/8/24.
//

import Foundation
extension CGSize {
	func aspectFit(in boundingSize: CGSize, insetBy insetAmount: CGFloat) -> CGSize {
		let scaledSize = self.aspectFit(in: boundingSize)
		return CGSize(width: scaledSize.width - insetAmount * 2, height: scaledSize.height - insetAmount * 2)
	}

	private func aspectFit(in boundingSize: CGSize) -> CGSize {
		let aspectWidth = boundingSize.width / width
		let aspectHeight = boundingSize.height / height
		let aspectRatio = min(aspectWidth, aspectHeight)

		return CGSize(width: width * aspectRatio, height: height * aspectRatio)
	}
}
