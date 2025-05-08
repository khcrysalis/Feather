//
//  NBSheetButton.swift
//  NimbleKit
//
//  Created by samara on 8.05.2025.
//

import SwiftUI

public struct NBSheetButton: View {
	private var _title: String
	
	public init(title: String) {
		self._title = title
	}
	
	public var body: some View {
		Text(_title)
			.frame(maxWidth: .infinity, maxHeight: .infinity)
			.background(Color.accentColor)
			.foregroundColor(.white)
			.clipShape(
				RoundedRectangle(cornerRadius: 12, style: .continuous)
			)
			.bold()
			.frame(height: 50)
			.padding()
	}
}
