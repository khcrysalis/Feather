//
//  UIImage+url.swift
//  Feather
//
//  Created by samara on 18.04.2025.
//

import UIKit.UIImage

extension UIImage {
	static public func fromFile(_ url: URL?) -> UIImage? {
		guard let url = url else {
			return nil
		}
		
		return UIImage(contentsOfFile: url.path)
	}
}

