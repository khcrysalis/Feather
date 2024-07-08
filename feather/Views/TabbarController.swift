//
//  TabbarController.swift
//  feather
//
//  Created by samara on 5/17/24.
//

import UIKit
import SwiftUI

class TabbarController: UITabBarController {

	override func viewDidLoad() {
		super.viewDidLoad()
		self.setupTabs()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
	}
	
	private func setupTabs() {
		let sources = self.createNavigation(with: "Sources", and: UIImage(named: "globe2"), vc: SourcesViewController())
		let apps = self.createNavigation(with: "Apps", and: UIImage(systemName: "square.grid.2x2.fill"), vc: AppsViewController())
		let certs = self.createNavigation(with: "Certificates", and: UIImage(named: "cert"), vc: CertificatesViewController())

		let settings = self.createNavigation(with: "Settings", and: UIImage(systemName: "gearshape.2.fill"), vc: SettingsViewController())

		self.setViewControllers([
			sources,
			apps,
			certs,
			settings
		], animated: false)
	}
	
	private func createNavigation(with title: String, and image: UIImage?, vc: UIViewController) -> UINavigationController {
		let nav = UINavigationController(rootViewController: vc)
		
		nav.tabBarItem.title = title
		nav.tabBarItem.image = image
		nav.viewControllers.first?.navigationItem.title = title
		
		return nav
	}
}
