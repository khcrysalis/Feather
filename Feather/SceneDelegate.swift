//
//  SceneDelegate.swift
//  Feather
//
//  Created by samsam on 5/25/26.
//

import UIKit
import struct SwiftUI.Color

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
	var window: UIWindow?

	func scene(
		_ scene: UIScene,
		willConnectTo session: UISceneSession,
		options connectionOptions: UIScene.ConnectionOptions
	) {
		guard let windowScene = scene as? UIWindowScene else { return }
		
		let window = UIWindow(windowScene: windowScene)
		let controller = TabBarController()
		window.rootViewController = controller
		
		if 
			let data = UserDefaults.standard.data(forKey: "Feather.userTintColor"),
			let color = try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: data) 
		{
			window.tintColor = color
		}
		
		window.overrideUserInterfaceStyle = UIUserInterfaceStyle(
			rawValue: UserDefaults.standard.integer(forKey: "Feather.userInterfaceStyle")
		) ?? .unspecified
		
		window.makeKeyAndVisible()
		
		self.window = window
	}
}
