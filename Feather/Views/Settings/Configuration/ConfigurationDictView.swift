//
//  SigningOptionsDictView.swift
//  Feather
//
//  Created by samara on 15.04.2025.
//

import SwiftUI

// MARK: - View
struct ConfigurationDictView: View {
	@State private var isAddingValue = false
	
	var title: String
	@Binding var dataDict: [String: String]
	
	// MARK: Body
	var body: some View {
		List {
			ForEach(dataDict.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
				Section(key) {
					Text(value).swipeActions(edge: .trailing) {
						_actions(key: key)
					}
				}
			}
		}
		.navigationTitle(title)
		.toolbar {
			FRToolbarButton(
				"Add",
				systemImage: "plus",
				style: .icon,
				placement: .topBarTrailing
			) {
				isAddingValue = true
			}
		}
		.navigationDestination(isPresented: $isAddingValue) {
			ConfigurationDictAddView(dataDict: $dataDict)
		}
	}
}

// MARK: - Extension: View
extension ConfigurationDictView {
	@ViewBuilder
	private func _actions(key: String) -> some View {
		Button(role: .destructive) {
			dataDict.removeValue(forKey: key)
		} label: {
			Label("Delete", systemImage: "trash")
		}
	}
}
