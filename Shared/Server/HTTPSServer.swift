//
//  HTTPSServer.swift
//  feather
//
//  Created by HAHALOSAH on 5/22/24.
//

import Foundation
import HttpSwift

var server = Server()
var serverIsRunning = false
var serverRunning: DispatchWorkItem?
var serverShouldStop = false

func getDocumentsDirectory() -> URL {
	let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
	let documentsDirectory = paths[0]
	return documentsDirectory
}

func runHTTPSServer() {
	if serverIsRunning {
		return
	}
	
	server.get("/manifest.plist") { request in
		let data = try! PropertyListSerialization.data(fromPropertyList: [
			"items": [
				[
					"assets": [
						[
							"kind": "software-package",
							"url": "https://localhost.direct:8443/tempsigned.ipa?uuid=\(UUID(uuidString: request.queryParams["uuid"] ?? "null")?.uuidString ?? "null")"
						]
					],
					"metadata": [
						"bundle-identifier": request.queryParams["bundleid"] ?? "null",
						"bundle-version": "1.0",
						"kind": "software",
						"title": request.queryParams["name"] ?? "(null)"
					]
				]
			]
		], format: .xml, options: 0)
		
		if serverShouldStop {
			stopHTTPSServer()
		}
		
		return .init(.ok, body: [Byte](data), headers: [
			"Content-Type": "text/plain"
		])
	}
	
	server.get("/tempsigned.ipa") { request in
		let path = NSHomeDirectory() + "/tmp/" + ((UUID(uuidString: request.queryParams["uuid"] ?? "null")?.uuidString ?? "null") + ".ipa")
		if !FileManager.default.fileExists(atPath: path) {
			return .init(.notFound)
		}
		
		if serverShouldStop {
			stopHTTPSServer()
		}
		Debug.shared.log(message: path)
		return .init(.ok, body: [Byte](FileManager.default.contents(atPath: path)!), headers: [
			"Content-Type": "application/octet-stream"
		])
	}
	
	serverRunning = DispatchWorkItem {
		if let pfxFilePath = getPFXFilePath() {
			do {
				Debug.shared.log(message: "\(pfxFilePath)")
				try server.run(port: 8443, certifiatePath: (pfxFilePath, ""))
			} catch {
				Debug.shared.log(message: "Failed to run server.", type: .error)
			}
		} else {
			Debug.shared.log(message: "Server Certificate Not Found.", type: .error)
		}
	}
	
	if let serverRunning = serverRunning {
		DispatchQueue(label: "https-server").async(execute: serverRunning)
	}
	
	serverIsRunning = true
}

func stopHTTPSServer() {
	guard serverIsRunning else { return }
	server.stop()
	serverIsRunning = false
	serverShouldStop = false
}

func requestCompletedAndStopServer() {
	serverShouldStop = true
}
