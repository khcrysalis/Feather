//
//  Server.swift
//  feather
//
//  Created by samara on 22.08.2024.
//  Copyright © 2024 Lakr Aream. All Rights Reserved.
//  ORIGINALLY LICENSED UNDER GPL-3.0, MODIFIED FOR USE FOR FEATHER
//

import Foundation
import Vapor
import NIOSSL
import NIOTLS

enum Status {
	case none
	case ready
	case sendingManifest
	case sendingPayload
	case completed(Result<Void, Error>)
	case broken(Error)
	
	var statusImage: String {
		switch self {
		case .none: return "archivebox.fill"
		case .ready: return "app.gift"
		case .sendingManifest, .sendingPayload: return "paperplane.fill"
		case .completed: return "app.badge.checkmark"
		case .broken: return "exclamationmark.triangle.fill"
		}
	}
	
	var statusLabel: String {
		switch self {
		case .none: return "Packaging"
		case .ready: return "Ready"
		case .sendingManifest: return "Sending Manifest"
		case .sendingPayload: return "Sending Payload"
		case .completed: return "Completed"
		case .broken: return "Error"
		}
	}
}

// MARK: - Class
class Installer: Identifiable, ObservableObject {
	@Published var status: Status = .none
	
	let id = UUID()
	let port = Int.random(in: 4000...8000)
	var needsShutdown = false
	
	var packageUrl: URL?
	var app: AppInfoPresentable
	private let _server: Application

	init(app: AppInfoPresentable) throws {
		self.app = app
		self._server = try Self.setupApp(port: port)
		
		try _configureRoutes()
		try _server.server.start()
		needsShutdown = true
		
		print("Server started on port \(port) for \(Self.sni)")
	}
	
	deinit {
		_shutdownServer()
	}
		
	private func _configureRoutes() throws {
		_server.get("*") { [weak self] req in
			guard let self else { return Response(status: .badGateway) }
			switch req.url.path {
			case plistEndpoint.path:
				self._updateStatus(.sendingManifest)
				return Response(status: .ok, version: req.version, headers: [
					"Content-Type": "text/xml",
				], body: .init(data: installManifestData))
			case displayImageSmallEndpoint.path:
				return Response(status: .ok, version: req.version, headers: [
					"Content-Type": "image/png",
				], body: .init(data: displayImageSmallData))
			case displayImageLargeEndpoint.path:
				return Response(status: .ok, version: req.version, headers: [
					"Content-Type": "image/png",
				], body: .init(data: displayImageLargeData))
			case payloadEndpoint.path:
				guard let packageUrl = packageUrl else {
					return Response(status: .notFound)
				}
				
				self._updateStatus(.sendingPayload)
				
				return req.fileio.streamFile(
					at: packageUrl.path
				) { result in
					self._updateStatus(.completed(result))
				}
			case "/install":
				print("helo")
				print(self.html)
				var headers = HTTPHeaders()
				headers.add(name: .contentType, value: "text/html")
				return Response(status: .ok, headers: headers, body: .init(string: self.html))
			default:
				return Response(status: .notFound)
			}
		}
	}
	
	private func _shutdownServer() {
		print("Server is shutting down!")
		guard needsShutdown else { return }
		
		needsShutdown = false
		_server.server.shutdown()
		_server.shutdown()
	}
	
	private func _updateStatus(_ newStatus: Status) {
		DispatchQueue.main.async {
			self.status = newStatus
		}
	}
		
	static func getServerMethod() -> Int {
		UserDefaults.standard.integer(forKey: "Feather.serverMethod")
	}
}
