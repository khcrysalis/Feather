//
//  UINavigationController+shouldPresentFullscreen.swift
//  feather
//
//  Created by samara on 9.12.2024.
//

extension UINavigationController {
	func shouldPresentFullScreen() {
		if UIDevice.current.userInterfaceIdiom == .pad {
			self.modalPresentationStyle = .formSheet
		} else {
			self.modalPresentationStyle = .fullScreen
		}
	}
}
