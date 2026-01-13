//
//  FRAppIconView.swift
//  Feather
//
//  Created by samara on 18.04.2025.
//

import SwiftUI

struct FRAppIconView: View {
	private var _app: AppInfoPresentable
	private var _size: CGFloat
	
	@State private var loadedIcon: UIImage? = nil
	@State private var isLoading = true
	
	init(app: AppInfoPresentable, size: CGFloat = 87) {
		self._app = app
		self._size = size
	}
	
	var body: some View {
		Group {
			if let uiImage = loadedIcon {
				Image(uiImage: uiImage)
					.appIconStyle(size: _size)
			} else if isLoading {
				Image("App_Unknown")
					.appIconStyle(size: _size)
			} else {
				Image("App_Unknown")
					.appIconStyle(size: _size)
			}
		}
		.task(id: _app.uuid) {
			await loadIconAsync()
		}
	}
	
	private func loadIconAsync() async {
		let image = await Task.detached(priority: .userInitiated) {
			return await self.resolveIcon()
		}.value
		
		await MainActor.run {
			self.loadedIcon = image
			self.isLoading = false
		}
	}

	private func resolveIcon() -> UIImage? {
		guard let bundleURL = Storage.shared.getAppDirectory(for: _app) else {
			return nil
		}
		
		// 1. System Render (Heavy)
		if let bundle = Bundle(url: bundleURL),
		   let systemIcon = FRIconServicesRenderer.icon(for: bundle) {
			return systemIcon
		}

		// 2. Manual Fallback
		if let iconName = _app.icon {
			let iconPath = bundleURL.appendingPathComponent(iconName).path
			return UIImage(contentsOfFile: iconPath)
		}
		
		return nil
	}
}
