//
//  CertificatesInfoEntitlementCellView.swift
//  Feather
//
//  Created by samara on 27.04.2025.
//

import SwiftUI

// MARK: - View
struct CertificatesInfoEntitlementCellView: View {
	let key: String
	let value: Any
	@State private var _isExpanded = false
	
	// MARK: Body
	var body: some View {
		if let dict = value as? [String: Any] {
			_makeDisclosureGroup(items: dict.map { ($0.key, $0.value) }.sorted { $0.0 < $1.0 })
		} else if let array = value as? [Any] {
			_makeDisclosureGroup(items: array.enumerated().map { ("\($0)", $1) })
		} else {
			HStack {
				Text(key)
				Spacer()
				Text(_formatted(value))
					.foregroundStyle(.secondary)
			}
		}
	}
	
	private func _makeDisclosureGroup(items: [(String, Any)]) -> some View {
		DisclosureGroup(isExpanded: $_isExpanded) {
			ForEach(items, id: \.0) { item in
				CertificatesInfoEntitlementCellView(key: item.0, value: item.1)
			}
		} label: {
			Text(key)
		}
	}
	
	private func _formatted(_ value: Any) -> String {
		switch value {
		case let bool as Bool: return bool ? "✓" : "✗"
		case let number as NSNumber: return number.stringValue
		case let string as String: return string
		default: return String(describing: value)
		}
	}
}
