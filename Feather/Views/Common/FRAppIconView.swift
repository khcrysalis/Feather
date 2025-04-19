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
	private var _cornerRadius: CGFloat
	
	init(app: AppInfoPresentable, size: CGFloat = 87, cornerRadius: CGFloat = 20) {
		self._app = app
		self._size = size
		self._cornerRadius = cornerRadius
	}
	
	var body: some View {
		if
			let iconFilePath = Storage.shared.getAppDirectory(for: _app)?.appendingPathComponent(_app.icon ?? ""),
			let uiImage = UIImage(contentsOfFile: iconFilePath.path)
		{
			Image(uiImage: uiImage)
				.appIconStyle(size: _size, cornerRadius: _cornerRadius)
		} else {
			Image("App_Unknown")
				.appIconStyle(size: _size)
		}
	}
}
