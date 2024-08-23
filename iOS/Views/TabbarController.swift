//
//  TabbarController.swift
//  feather
//
//  Created by samara on 5/17/24.
//  Copyright (c) 2024 Samara M (khcrysalis)
//

import UIKit

class TabbarController: UITabBarController, UITabBarControllerDelegate {

	override func viewDidLoad() {
		super.viewDidLoad()
		self.setupTabs()
		self.delegate = self
	}
	
	private func setupTabs() {
		let sources = self.createNavigation(with: "Sources", and: UIImage(named: "globe2"), vc: SourcesViewController())
		let n = self.createNavigation(with: "Library", and: UIImage(systemName: "square.grid.2x2.fill"), vc: LibraryViewController())
		let settings = self.createNavigation(with: "Settings", and: UIImage(systemName: "gearshape.2.fill"), vc: SettingsViewController())

		self.setViewControllers([sources, n, settings], animated: false)
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


