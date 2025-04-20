//
//  Binding+optional.swift
//  Feather
//
//  Created by samara on 19.04.2025.
//

import SwiftUI

extension Binding {
	func optional() -> Binding<Value?> {
		Binding<Value?>(
			get: { self.wrappedValue },
			set: { if let value = $0 { self.wrappedValue = value } }
		)
	}
}
