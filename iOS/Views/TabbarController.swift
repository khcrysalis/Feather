//
//  TabbarController.swift
//  feather
//
//  Created by samara on 5/17/24.
//  Copyright (c) 2024 Samara M (khcrysalis)
//

import UIKit
import SwiftUI

class TabbarController: UITabBarController, UITabBarControllerDelegate {

	override func viewDidLoad() {
		super.viewDidLoad()
		self.setupTabs()
		self.delegate = self
	}
	
	private func setupTabs() {
		let sources = self.createNavigation(with: String.localized("TAB_SOURCES"), and: UIImage(named: "globe2"), vc: SourcesViewController())
		let library = self.createNavigation(with: String.localized("TAB_LIBRARY"), and: UIImage(systemName: "square.grid.2x2.fill"), vc: LibraryViewController())
		let settings = self.createNavigation(with: String.localized("TAB_SETTINGS"), and: UIImage(systemName: "gearshape.2.fill"), vc: SettingsViewController())

		var viewControllers = [sources, library, settings]

		if Preferences.beta {
			let debug = self.createNavigation(with: "Debug", and: UIImage(systemName: "ladybug.fill"), vc: DebugHostingController(rootView: DebugViewController()))
			viewControllers.append(debug)
		}

		self.setViewControllers(viewControllers, animated: false)
	}
	
	private func createNavigation(with title: String, and image: UIImage?, vc: UIViewController) -> UINavigationController {
		let nav = UINavigationController(rootViewController: vc)
		nav.tabBarItem.title = title
		nav.tabBarItem.image = image
		nav.viewControllers.first?.navigationItem.title = title
		return nav
	}
	
	func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
		guard let fromView = selectedViewController?.view, let toView = viewController.view else { return false }
		
		if fromView != toView {
			UIView.transition(from: fromView, to: toView, duration: 0.15, options: [.transitionCrossDissolve], completion: nil)
		}
		
		return true
	}
}


