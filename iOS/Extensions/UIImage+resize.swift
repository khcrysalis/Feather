//
//  UIImage+resize.swift
//  feather
//
//  Created by samara on 8/13/24.
//

import Foundation
import AVFoundation
extension UIImage {
	func resizeToSquare() -> UIImage? {
		// Determine the size for the square
		let size = min(self.size.width, self.size.height)
		let rect = CGRect(x: (self.size.width - size) / 2,
						  y: (self.size.height - size) / 2,
						  width: size,
						  height: size)
		
		// Create a new graphics context with the square size
		UIGraphicsBeginImageContextWithOptions(CGSize(width: size, height: size), false, self.scale)
		// Draw the image in the square context
		self.draw(at: CGPoint(x: -rect.origin.x, y: -rect.origin.y))
		// Get the new square image from the context
		let squareImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		
		return squareImage
	}
}

public extension UIImage {
	/// Resize image while keeping the aspect ratio. Original image is not modified.
	/// - Parameters:
	///   - width: A new width in pixels.
	///   - height: A new height in pixels.
	/// - Returns: Resized image.
	func resize(_ width: Int, _ height: Int) -> UIImage {
		// Keep aspect ratio
		let maxSize = CGSize(width: width, height: height)

		let availableRect = AVFoundation.AVMakeRect(
			aspectRatio: self.size,
			insideRect: .init(origin: .zero, size: maxSize)
		)
		let targetSize = availableRect.size

		// Set scale of renderer so that 1pt == 1px
		let format = UIGraphicsImageRendererFormat()
		format.scale = 1
		let renderer = UIGraphicsImageRenderer(size: targetSize, format: format)

		// Resize the image
		let resized = renderer.image { _ in
			self.draw(in: CGRect(origin: .zero, size: targetSize))
		}

		return resized
	}
}
