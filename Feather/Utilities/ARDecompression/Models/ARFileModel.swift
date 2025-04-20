//
//  ARFile.swift
//  Feather
//
//  Created by samara on 20.04.2025.
//

import Foundation

struct ARFileModel {
	var name: String
	var modificationDate: Date
	var ownerId: Int
	var groupId: Int
	var mode: Int
	var size: Int
	var content: Data
}
