//
//  SigningOptionsDictView.swift
//  Feather
//
//  Created by samara on 15.04.2025.
//

import SwiftUI

struct SigningOptionsDictView: View {
	var title: String
	@Binding var dataDict: [String: String]
	
	@State private var isAddingValue = false
	@State private var newKey = ""
	@State private var newValue = ""
	@State private var showOverrideAlert = false
	
	var saveButtonDisabled: Bool {
		newKey.isEmpty || newValue.isEmpty
	}
	
	var body: some View {
		List {
			ForEach(dataDict.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
				Section(key) {
					Text(value)
					.swipeActions(edge: .trailing) {
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
		.sheet(isPresented: $isAddingValue) {
			_addValue()
				.presentationDetents([.medium])
				.alert("Key Already Exists", isPresented: $showOverrideAlert) {
					Button("Cancel", role: .cancel) { }
					Button("Replace", role: .destructive) {
						dataDict[newKey] = newValue
						isAddingValue = false
						newKey = ""
						newValue = ""
					}
				} message: {
					Text("An entry with the identifier '\(newKey)' already exists. Do you want to replace it?")
				}
		}
	}
	
	@ViewBuilder
	private func _actions(key: String) -> some View {
		Button(role: .destructive) {
			dataDict.removeValue(forKey: key)
		} label: {
			Label("Delete", systemImage: "trash")
		}
	}
	
	@ViewBuilder
	private func _addValue() -> some View {
		FRNavigationView("New Entry") {
			Form {
				FRSection("New") {
					TextField("Identifier", text: $newKey)
					TextField("Replacement", text: $newValue)
				}
				.autocapitalization(.none)
			}
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				FRToolbarButton(
					"Cancel",
					systemImage: "xmark",
					style: .text,
					placement: .cancellationAction
				) {
					isAddingValue = false
					newKey = ""
					newValue = ""
				}
				
				FRToolbarButton(
					"Save",
					systemImage: "plus",
					style: .text,
					placement: .confirmationAction,
					isDisabled: saveButtonDisabled
				) {
					if !newKey.isEmpty && !newValue.isEmpty {
						if dataDict[newKey] != nil {
							showOverrideAlert = true
						} else {
							dataDict[newKey] = newValue
							isAddingValue = false
							newKey = ""
							newValue = ""
						}
					}
				}
			}
		}
	}
}
