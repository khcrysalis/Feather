//
//  mobileprovision.swift
//  plethora
//
//  Created by Jacob Prezant on 5/31/25.
//

import Foundation

func extractAppID(fromProvisionAt url: URL) -> String? {
    guard let data = try? Data(contentsOf: url),
          let contentString = String(data: data, encoding: .isoLatin1),
          let startRange = contentString.range(of: "<?xml"),
          let endRange = contentString.range(of: "</plist>") else {
        return nil
    }

    let xmlString = String(contentString[startRange.lowerBound...endRange.upperBound])
    guard let xmlData = xmlString.data(using: .utf8) else {
        return nil
    }

    var format = PropertyListSerialization.PropertyListFormat.xml
    guard let plist = try? PropertyListSerialization.propertyList(from: xmlData, options: [], format: &format) as? [String: Any],
          let entitlements = plist["Entitlements"] as? [String: Any],
          let appID = entitlements["application-identifier"] as? String else {
        return nil
    }

    let idComponents = appID.split(separator: ".", maxSplits: 1)
    guard idComponents.count == 2 else { return nil }
    return String(idComponents[1])
}
