//
//  Danger
//  plethora
//
//  Created by Jacob Prezant on 5/31/25.
//

import Foundation
import ZIPFoundation

func getOriginalBundleID(from ipaURL: URL) -> String? {
    let archive: Archive
    do {
        archive = try Archive(url: ipaURL, accessMode: .read)
    } catch {
        return nil
    }

    guard let infoPlistEntry = archive.first(where: {
        $0.path.hasSuffix(".app/Info.plist") && $0.path.hasPrefix("Payload/")
    }) else {
        return nil
    }

    var infoPlistData = Data()
    _ = try? archive.extract(infoPlistEntry) { data in
        infoPlistData.append(data)
    }

    var format = PropertyListSerialization.PropertyListFormat.xml
    let plist = try? PropertyListSerialization.propertyList(from: infoPlistData, options: [], format: &format)

    guard let plistDict = plist as? [String: Any],
          let originalBundleID = plistDict["CFBundleIdentifier"] as? String else {
        return nil
    }

    return originalBundleID
}

func updateBundleID(in ipaURL: URL, usingProvisionAt provisionURL: URL) -> String? {
    guard ipaURL.startAccessingSecurityScopedResource() else {
        return nil
    }
    defer { ipaURL.stopAccessingSecurityScopedResource() }

    let archive: Archive
    do {
        archive = try Archive(url: ipaURL, accessMode: .update)
    } catch {
        return nil
    }

    guard let infoPlistEntry = archive.first(where: {
        $0.path.hasSuffix(".app/Info.plist") && $0.path.hasPrefix("Payload/")
    }) else {
        return nil
    }

    var infoPlistData = Data()
    _ = try? archive.extract(infoPlistEntry) { data in
        infoPlistData.append(data)
    }

    var format = PropertyListSerialization.PropertyListFormat.xml
    guard let plist = try? PropertyListSerialization.propertyList(from: infoPlistData, options: [], format: &format),
          var plistDict = plist as? [String: Any],
          let appID = extractAppID(fromProvisionAt: provisionURL) else {
        return nil
    }

    let newBundleID = appID  
    let originalBundleID = plistDict["CFBundleIdentifier"] as? String ?? ""

    plistDict["CFBundleIdentifier"] = newBundleID

    func recursivelyReplaceBundleID(in object: Any) -> Any {
        if let string = object as? String {
            return string.replacingOccurrences(of: originalBundleID, with: newBundleID)
        } else if let array = object as? [Any] {
            return array.map { recursivelyReplaceBundleID(in: $0) }
        } else if let dict = object as? [String: Any] {
            var newDict = [String: Any]()
            for (key, value) in dict {
                newDict[key] = recursivelyReplaceBundleID(in: value)
            }
            return newDict
        } else {
            return object
        }
    }

    plistDict = recursivelyReplaceBundleID(in: plistDict) as? [String: Any] ?? plistDict

    guard let updatedPlistData = try? PropertyListSerialization.data(fromPropertyList: plistDict, format: .xml, options: 0) else {
        return nil
    }

    _ = try? archive.remove(infoPlistEntry)
    try? archive.addEntry(with: infoPlistEntry.path, type: .file, uncompressedSize: Int64(updatedPlistData.count), compressionMethod: .none, provider: { (position: Int64, size: Int) -> Data in
        return updatedPlistData.subdata(in: Int(position)..<Int(position) + size)
    })

    return newBundleID
}
