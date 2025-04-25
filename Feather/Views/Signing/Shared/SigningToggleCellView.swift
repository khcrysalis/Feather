//
//  DylibToggleView.swift
//  Feather
//
//  Created by samara on 20.04.2025.
//


import SwiftUI

struct SigningToggleCellView<T>: View {
	let title: String
	@Binding var options: T?
	let arrayKeyPath: WritableKeyPath<T, [String]>
	
	var body: some View {
		Toggle(title, isOn: Binding(
			get: {
				guard let options = options else { return false }
				return !options[keyPath: arrayKeyPath].contains(title)
			},
			set: { isOn in
				if isOn {
					_removeItem()
				} else {
					_addItem()
				}
			}
		))
	}
	
	private func _removeItem() {
		guard var opts = options else { return }
		opts[keyPath: arrayKeyPath].removeAll { $0 == title }
		options = opts
	}
	
	private func _addItem() {
		guard var opts = options else { return }
		if !opts[keyPath: arrayKeyPath].contains(title) {
			opts[keyPath: arrayKeyPath].append(title)
		}
		options = opts
	}
}
