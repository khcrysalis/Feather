//
//  SectionIcons.swift
//  feather
//
//  Created by samara on 5/18/24.
//

import Foundation
import UIKit
import Nuke

class SectionIcons {
	@available(iOS 13.0, *)
	static public func sectionIcon(to cell: UITableViewCell, with symbolName: String, backgroundColor: UIColor) {
		let symbolConfig = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
		guard let symbolImage = UIImage(systemName: symbolName, withConfiguration: symbolConfig)?.withTintColor(.white, renderingMode: .alwaysOriginal) else {
			return
		}
		#if os(tvOS)
		let imageSize = CGSize(width: 75, height: 75)
		#else
		let imageSize = CGSize(width: 30, height: 30)
		#endif
		let insetAmount: CGFloat = 3
		let scaledSymbolSize = symbolImage.size.aspectFit(in: imageSize, insetBy: insetAmount)

		let coloredBackgroundImage = UIGraphicsImageRenderer(size: imageSize).image { context in
			backgroundColor.setFill()
			UIBezierPath(roundedRect: CGRect(origin: .zero, size: imageSize), cornerRadius: 7).fill()
		}

		let mergedImage = UIGraphicsImageRenderer(size: imageSize).image { context in
			coloredBackgroundImage.draw(in: CGRect(origin: .zero, size: imageSize))
			symbolImage.draw(in: CGRect(
				x: (imageSize.width - scaledSymbolSize.width) / 2,
				y: (imageSize.height - scaledSymbolSize.height) / 2,
				width: scaledSymbolSize.width,
				height: scaledSymbolSize.height
			))
		}

		cell.imageView?.image = mergedImage
		cell.imageView?.layer.cornerRadius = 7
		cell.imageView?.clipsToBounds = true
		cell.imageView?.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.3).cgColor
	}
	
	static public func sectionImage(to cell: UITableViewCell, with originalImage: UIImage, size: CGSize = CGSize(width: 42, height: 42), radius: Int = 10) {
		let resizedImage = UIGraphicsImageRenderer(size: size).image { context in
			originalImage.draw(in: CGRect(origin: .zero, size: size))
		}
		
		cell.imageView?.image = resizedImage
		cell.imageView?.layer.cornerCurve = .continuous
		cell.imageView?.layer.cornerRadius = CGFloat(radius)
		cell.imageView?.layer.borderWidth = 1
		cell.imageView?.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.3).cgColor
		cell.imageView?.clipsToBounds = true
	}
	
	static public func loadImageFromURL(from url: URL, for cell: UITableViewCell, at indexPath: IndexPath, in tableView: UITableView) {
		let request = ImageRequest(url: url)
		
		if let cachedImage = ImagePipeline.shared.cache.cachedImage(for: request)?.image {
			SectionIcons.sectionImage(to: cell, with: cachedImage)
		} else {
			ImagePipeline.shared.loadImage(
				with: request,
				progress: nil,
				completion: { result in
					switch result {
					case .success(let imageResponse):
						DispatchQueue.main.async {
							SectionIcons.sectionImage(to: cell, with: imageResponse.image)
							tableView.reloadRows(at: [indexPath], with: .none)
						}
					case .failure(let error):
						print("Image loading failed with error: \(error)")
					}
				}
			)
		}
	}

}

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
