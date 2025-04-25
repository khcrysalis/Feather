//
//  TabEnum.swift
//  feather
//
//  Created by samara on 22.03.2025.
//

import SwiftUI

enum TabEnum: String, CaseIterable, Hashable {
	case sources
	case library
	case settings
	case certificates
	
	var title: String {
		switch self {
		case .sources:     	return "Sources"
		case .library: 		return "Library"
		case .settings: 	return "Settings"
		case .certificates:	return "Certificates"
		}
	}
	
	var icon: String {
		switch self {
		case .sources: 		return "globe.desk"
		case .library: 		return "square.grid.2x2"
		case .settings: 	return "gearshape.2"
		case .certificates: return "person.text.rectangle"
		}
	}
	
	@ViewBuilder
	static func view(for tab: TabEnum) -> some View {
		switch tab {
		case .sources: SourcesView()
		case .library: LibraryView()
		case .settings: SettingsView()
		case .certificates: FRNavigationView("Certificates") { CertificatesView() }
		}
	}
	
	static var defaultTabs: [TabEnum] {
		return [
			.sources,
			.library,
			.settings
		]
	}
	
	static var customizableTabs: [TabEnum] {
		return [
			.certificates
		]
	}
}
