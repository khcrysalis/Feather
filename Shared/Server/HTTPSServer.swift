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
        .init(.ok, body: [Byte](try! PropertyListSerialization.data(fromPropertyList: [
            "items": [
                [
                    "assets": [
                        [
                            "kind": "software-package",
                            "url": "https://localhost.direct:8443/app.ipa?uuid=\(UUID(uuidString: request.queryParams["uuid"] ?? "null")?.uuidString ?? "null")" // bad code ikik
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
        ], format: .xml, options: 0)), headers: [
            "Content-Type": "text/plain"
        ])
    }
    server.get("/app.ipa") { request in
        let path = NSHomeDirectory() + "/tmp/" + ((UUID(uuidString: request.queryParams["uuid"] ?? "null")?.uuidString ?? "null") + ".ipa") // more bad code please forgive me
        if !FileManager.default.fileExists(atPath: path) {
            return .init(.notFound)
        }
        return .init(.ok, body: [Byte](FileManager.default.contents(atPath: path)!), headers: [
            "Content-Type": "application/octet-stream"
        ])
    }
    DispatchQueue(label: "https-server").async {
        try? server.run(port: 8443, certifiatePath: (Bundle.main.url(forResource: "localhost.direct", withExtension: "pfx")!, ""))
    }
    serverIsRunning = true
}
