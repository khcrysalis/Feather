//
//  UIImage+resize.swift
//  feather
//
//  Created by samara on 8/13/24.
//

import UIKit.UIImage
import AVFoundation

extension UIImage {
	public func resizeToSquare() -> UIImage? {
		let size = min(self.size.width, self.size.height)
		let rect = CGRect(
			x: (self.size.width - size) / 2,
			y: (self.size.height - size) / 2,
			width: size,
			height: size
		)
		
		UIGraphicsBeginImageContextWithOptions(CGSize(width: size, height: size), false, self.scale)
		self.draw(at: CGPoint(x: -rect.origin.x, y: -rect.origin.y))
		let squareImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		
		return squareImage
	}
	
	public func resize(_ width: Int, _ height: Int) -> UIImage {
		let maxSize = CGSize(width: width, height: height)
		
		let availableRect = AVFoundation.AVMakeRect(
			aspectRatio: self.size,
			insideRect: .init(origin: .zero, size: maxSize)
		)
		let targetSize = availableRect.size
		
		let format = UIGraphicsImageRendererFormat()
		format.scale = 1
		let renderer = UIGraphicsImageRenderer(size: targetSize, format: format)
		
		let resized = renderer.image { _ in
			self.draw(in: CGRect(origin: .zero, size: targetSize))
		}
		
		return resized
	}
}
