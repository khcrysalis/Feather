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
	#if DEBUG
	case debug
	#endif
	
	
	var title: String {
		switch self {
		case .sources:     	return "Sources"
		case .library: 		return "Library"
		case .settings: 	return "Settings"
		case .certificates:	return "Certificates"
		#if DEBUG
		case .debug:		return "Debug"
		#endif
		}
	}
	
	var icon: String {
		switch self {
		case .sources: 		return "globe.desk"
		case .library: 		return "square.grid.2x2"
		case .settings: 	return "gearshape.2"
		case .certificates: return "person.text.rectangle"
		#if DEBUG
		case .debug:		return "hammer.fill"
		#endif
		}
	}
	
	@ViewBuilder
	static func view(for tab: TabEnum) -> some View {
		switch tab {
		case .sources: SourcesView()
		case .library: LibraryView()
		case .settings: SettingsView()
		case .certificates: EmptyView()
		#if DEBUG
		case .debug:		DebugView()
		#endif
		}
	}
	
	static var defaultTabs: [TabEnum] {
		var tabs: [TabEnum] = [
			.sources,
			.library,
			.settings
		]
		
		#if DEBUG
		tabs.append(.debug)
		#endif
		
		return tabs
	}
	
	static var customizableTabs: [TabEnum] {
		return [
			.certificates
		]
	}
}
