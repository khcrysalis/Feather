//
//  TabbarController.swift
//  feather
//
//  Created by samara on 5/17/24.
//  Copyright (c) 2024 Samara M (khcrysalis)
//

import SwiftUI

struct TabbarView: View {
	@State private var selectedTab: Tab = Tab(rawValue: UserDefaults.standard.string(forKey: "selectedTab") ?? "sources") ?? .sources
	
	enum Tab: String {
		case sources
		case library
		case settings
	}

	var body: some View {
		TabView(selection: $selectedTab) {
			tab(for: .sources)
			tab(for: .library)
			tab(for: .settings)
		}
		.onChange(of: selectedTab) { newTab in
			UserDefaults.standard.set(newTab.rawValue, forKey: "selectedTab")
		}
	}

	@ViewBuilder
	func tab(for tab: Tab) -> some View {
		switch tab {
		case .sources:
			NavigationViewController(SourcesViewController.self, title: String.localized("TAB_SOURCES"))
				.edgesIgnoringSafeArea(.all)
				.tabItem { Label(String.localized("TAB_SOURCES"), systemImage: "books.vertical.fill") }
				.tag(Tab.sources)
		case .library:
			NavigationViewController(LibraryViewController.self, title: String.localized("TAB_LIBRARY"))
				.edgesIgnoringSafeArea(.all)
				.tabItem { Label(String.localized("TAB_LIBRARY"), systemImage: "square.grid.2x2.fill") }
				.tag(Tab.library)
		case .settings:
			NavigationViewController(SettingsViewController.self, title: String.localized("TAB_SETTINGS"))
				.edgesIgnoringSafeArea(.all)
				.tabItem { Label(String.localized("TAB_SETTINGS"), systemImage: "gearshape.2.fill") }
				.tag(Tab.settings)
		}
	}
}


struct NavigationViewController<Content: UIViewController>: UIViewControllerRepresentable {
	let content: Content.Type
	let title: String

	init(_ content: Content.Type, title: String) {
		self.content = content
		self.title = title
	}

	func makeUIViewController(context: Context) -> UINavigationController {
		let viewController = content.init()
		viewController.navigationItem.title = title
		return UINavigationController(rootViewController: viewController)
	}
	
	func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {}
}
