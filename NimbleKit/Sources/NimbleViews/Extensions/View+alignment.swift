//
//  View+alignment.swift
//  Feather
//
//  Created by samara on 14.04.2025.
//

import SwiftUI

extension View {
	@ViewBuilder
	public func alignment(for alignment: NBToolbarAlignment) -> some View {
		switch alignment {
		case .leading:
			self.padding(.leading, -9)
		case .trailing:
			self.padding(.trailing, -9)
		case .none:
			self
		}
	}
}
