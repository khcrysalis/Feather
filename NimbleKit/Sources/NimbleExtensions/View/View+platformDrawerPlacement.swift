//
//  View+platformDrawerPlacement.swift
//  NimbleKit
//
//  Created by samara on 5.05.2025.
//

import SwiftUI

extension SearchFieldPlacement {
	@MainActor public static func platform() -> SearchFieldPlacement {
		UIDevice.current.userInterfaceIdiom == .pad ? .automatic : .navigationBarDrawer(displayMode: .always)
	}
}
