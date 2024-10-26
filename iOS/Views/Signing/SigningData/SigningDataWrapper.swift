//
//  SigningDataWrapper.swift
//  feather
//
//  Created by samara on 25.10.2024.
//

import Foundation

class SigningDataWrapper: ObservableObject {
	@Published var signingOptions: SigningOptions

	init(signingOptions: SigningOptions) {
		self.signingOptions = signingOptions
	}
}
