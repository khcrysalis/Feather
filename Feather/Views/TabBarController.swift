//
//  TabbarController.swift
//  Feather
//
//  Created by samsam on 5/8/26.
//

import UIKit
import SwiftUI

final class TabBarController: UITabBarController {
	override func viewDidLoad() {
		super.viewDidLoad()
		
		if #available(iOS 18.0, *) {
			self.mode = .tabSidebar
		}
		
		_setupTabs()
	}
	
	private func _setupTabs() {
		let files = _createNavigation(
			with: "Files",
			using: UIImage(systemName: "folder.fill"),
			controller: UIViewController()
		)
		
		let sources = _createNavigation(
			with: "Sources",
			using: UIImage(systemName: "globe.desk.fill"),
			controller: UIHostingController(rootView: SourcesView().environment(\.managedObjectContext, Storage.shared.context)),
			withNavigation: false,
		)
		
		let library = _createNavigation(
			with: "Apps",
			using: UIImage(systemName: "square.grid.2x2.fill"),
			controller: UIHostingController(rootView: LibraryView().environment(\.managedObjectContext, Storage.shared.context)),
			withNavigation: false,
		)
		
		let settings = _createNavigation(
			with: "Settings",
			using: UIImage(systemName: "gearshape.2.fill"),
			controller: SettingsViewController(),
		)
		
		self.setViewControllers([
			files,
			sources,
			library,
			settings,
		], animated: false)
	}
	
	#warning("remove swiftui remnants")
	private func _createNavigation(
		with title: String,
		using image: UIImage?,
		controller: UIViewController,
		withNavigation: Bool = true
	) -> UIViewController {
		if withNavigation {
			let nav = UINavigationController(rootViewController: controller)
			nav.tabBarItem.title = title
			nav.tabBarItem.image = image
			return nav
		} else {
			controller.tabBarItem.title = title
			controller.tabBarItem.image = image
			return controller
		}
	}
}
