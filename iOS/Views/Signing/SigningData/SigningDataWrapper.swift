//
//  SigningDataWrapper.swift
//  feather
//
//  Created by samara on 25.10.2024.
//

import Foundation

class SigningMainDataWrapper: ObservableObject {
	@Published var mainOptions: MainSigningOptions

	init(mainOptions: MainSigningOptions) {
		self.mainOptions = mainOptions
	}
}

class SigningDataWrapper: ObservableObject {
	@Published var signingOptions: SigningOptions

	init(signingOptions: SigningOptions) {
		self.signingOptions = signingOptions
	}
}
