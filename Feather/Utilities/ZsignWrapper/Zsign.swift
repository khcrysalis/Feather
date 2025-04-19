//
//  Zsign.swift
//  Feather
//
//  Created by samara on 17.04.2025.
//

import Zsign

final class Zsign {
	static func injectDyLib(appExecutable: String, with path: String, weak: Bool = true) -> Bool {
		InjectDyLib(appExecutable, path, weak)
	}
	
	static func removeDylibs(appExecutable: String) -> Bool  {
		UninstallDylibs(appExecutable, [])
	}
	
	static func listDylibs(appExecutable: String) -> [String] {
		ListDylibs(appExecutable)
	}
	
	static func changeDylibPath(appExecutable: String, for old: String, with new: String) -> Bool {
		ChangeDylibPath(appExecutable, old, new)
	}
	
	static func sign(
		appPath: String = "",
		provisionPath: String = "",
		p12Path: String = "",
		p12Password: String = "",
		customIdentifier: String = "",
		customName: String = "",
		customVersion: String = "",
		removeProvision: Bool = true
	) -> Bool {
		if zsign(
			appPath,
			provisionPath,
			p12Path,
			p12Password,
			customIdentifier,
			customName,
			customVersion,
			removeProvision
		) != 0 {
			return false
		}
		return true
	}
}
