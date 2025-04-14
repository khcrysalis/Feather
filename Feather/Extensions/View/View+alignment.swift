//
//  View+alignment.swift
//  Feather
//
//  Created by samara on 14.04.2025.
//

import SwiftUI

extension View {
	@ViewBuilder
	public func alignment(for alignment: FRToolbarAlignment) -> some View {
		switch alignment {
		case .leading:
			self.padding(.leading, -18)
		case .trailing:
			self.padding(.trailing, -18)
		case .none:
			self
		}
	}
}
