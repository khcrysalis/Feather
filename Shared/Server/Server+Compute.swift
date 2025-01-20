//
//  Server+Compute.swift
//  feather
//
//  Created by samara on 22.08.2024.
//  Copyright © 2024 Lakr Aream. All Rights Reserved.
//  ORIGINALLY LICENSED UNDER GPL-3.0, MODIFIED FOR USE FOR FEATHER
//

import Foundation

extension Installer {
	
	var pongEndpoint: URL {
		var comps = URLComponents()
		comps.scheme = Preferences.userSelectedServer ? "http" : "https"
		comps.host = Self.sni
		comps.path = "/ping"
		comps.port = port
		return comps.url!
	}
	
	var plistEndpoint: URL {
		var comps = URLComponents()
		comps.scheme = Preferences.userSelectedServer ? "http" : "https"
		comps.host = Self.sni
		comps.path = "/\(id).plist"
		comps.port = port
		return comps.url!
	}

	var payloadEndpoint: URL {
		var comps = URLComponents()
		comps.scheme = Preferences.userSelectedServer ? "http" : "https"
		comps.host = Self.sni
		comps.path = "/\(id).ipa"
		comps.port = port
		return comps.url!
	}
	
	var pageEndpoint: URL {
		var comps = URLComponents()
		comps.scheme = Preferences.userSelectedServer ? "http" : "https"
		comps.host = Self.sni
		comps.path = "/i"
		comps.port = port
		return comps.url!
	}

	var iTunesLink: URL {
		var comps = URLComponents()
		comps.scheme = "itms-services"
		comps.path = "/"
		comps.queryItems = [
			URLQueryItem(name: "action", value: "download-manifest"),
			URLQueryItem(name: "url", value: plistEndpoint.absoluteString),
		]
		comps.port = port
		return comps.url!
	}

	var displayImageSmallEndpoint: URL {
		var comps = URLComponents()
		comps.scheme = "https"
		comps.host = Self.sni
		comps.path = "/app57x57.png"
		comps.port = port
		return comps.url!
	}

	var displayImageSmallData: Data {
		createWhite(57)
	}

	var displayImageLargeEndpoint: URL {
		var comps = URLComponents()
		comps.scheme = "https"
		comps.host = Self.sni
		comps.path = "/app512x512.png"
		comps.port = port
		return comps.url!
	}

	var displayImageLargeData: Data {
		createWhite(512)
	}
	
	func createWhite(_ r: CGFloat) -> Data {
		let renderer = UIGraphicsImageRenderer(size: .init(width: r, height: r))
		let image = renderer.image { ctx in
			Preferences.appTintColor.uiColor.setFill()
			ctx.fill(.init(x: 0, y: 0, width: r, height: r))
		}
		return image.pngData()!
	}

	var indexHtml: String {
		"""
		<html> <head> <meta http-equiv="refresh" content="0;url=\(iTunesLink.absoluteString)"> </head> </html>
		"""
	}

	var installManifest: [String: Any] {
		[
			"items": [
				[
					"assets": [
						[
							"kind": "software-package",
							"url": payloadEndpoint.absoluteString,
						],
						[
							"kind": "display-image",
							"url": displayImageSmallEndpoint.absoluteString,
						],
						[
							"kind": "full-size-image",
							"url": displayImageLargeEndpoint.absoluteString,
						],
					],
					"metadata": [
						"bundle-identifier": metadata.id,
						"bundle-version": metadata.version,
						"kind": "software",
						"title": metadata.name,
					],
				],
			],
		]
	}

	var installManifestData: Data {
		(try? PropertyListSerialization.data(
			fromPropertyList: installManifest,
			format: .xml,
			options: .zero
		)) ?? .init()
	}
}
