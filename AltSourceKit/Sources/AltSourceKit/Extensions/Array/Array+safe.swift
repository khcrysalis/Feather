//
//  Array+safe.swift
//  Feather
//
//  Created by Lakhan Lothiyi on 19/04/2025.
//

extension Array {
	/// Returns the element at the specified index if it is within bounds, otherwise nil.
	///
	/// - Parameter index: The index of the element to return.
	/// - Returns: The element at the specified index, or nil if the index is out of bounds.
	subscript(safe index: Int) -> Element? {
		if indices.contains(index) {
			return self[index]
		}
		return nil
	}
}
