//
//  Array+Sorted.swift
//  Feather
//
//  Created by Lakhan Lothiyi on 19/04/2025.
//

import Foundation

extension Array where Element: Comparable {
	/// Sorts an array using key paths.
	func sorted<T: Comparable>(path keyPath: KeyPath<Element, T>) -> [Element] {
		self.sorted { $0[keyPath: keyPath] < $1[keyPath: keyPath] }
	}
}
