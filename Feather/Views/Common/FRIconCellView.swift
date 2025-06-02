//
//  FRIconCellView.swift
//  NimbleKit
//
//  Created by samara on 3.05.2025.
//

import SwiftUI
import NukeUI
import NimbleViews

// MARK: - View
struct FRIconCellView: View {
	var title: String
	var subtitle: String
	var iconUrl: URL?
	var isCircle: Bool = false
	
	// MARK: Body
	var body: some View {
		HStack(spacing: 9) {
			if let iconURL = iconUrl {
				LazyImage(url: iconURL) { state in
					if let image = state.image {
						image.appIconStyle(isCircle: isCircle)
					} else {
						standardIcon
					}
				}
			} else {
				standardIcon
			}
			
			NBTitleWithSubtitleView(
				title: title,
				subtitle: subtitle,
				linelimit: 0
			)
		}
	}
	
	var standardIcon: some View {
		Image("App_Unknown")
			.appIconStyle(isCircle: isCircle)
	}
}
