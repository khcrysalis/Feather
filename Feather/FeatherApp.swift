//
//  FeatherApp.swift
//  Feather
//
//  Created by samara on 10.04.2025.
//

import SwiftUI

@main
struct FeatherApp: App {
	let storage = Storage.shared

    var body: some Scene {
        WindowGroup {
			if #available(iOS 18, *) {
				ExtendedTabbarView()
					.environment(\.managedObjectContext, storage.context)
			} else {
				TabbarView()
					.environment(\.managedObjectContext, storage.context)
			}
        }
    }
}
