//
//  ZsignHandler.swift
//  Feather
//
//  Created by samara on 17.04.2025.
//

import Foundation

final class ZsignHandler {
	private var _appUrl: URL
	private var _options: Options
	
	init(appUrl: URL, options: Options = OptionsManager.shared.options) {
		self._appUrl = appUrl
		self._options = options
	}
	
	func sign() async throws {
		if Zsign.sign(
			appPath: _appUrl.relativePath,
			provisionPath: "",
			p12Path: "",
			p12Password: ""
		) {
			
		}
	}
}
