//
//  FRSITableViewCOntroller.swift
//  feather
//
//  Created by samara on 6.03.2025.
//

// Feather Signing TableView Controller

class FRSITableViewCOntroller: FRSTableViewController {
	
	var signingDataWrapper: SigningDataWrapper
	var mainOptions: SigningMainDataWrapper
	
	init(signingDataWrapper: SigningDataWrapper, mainOptions: SigningMainDataWrapper) {
		self.signingDataWrapper = signingDataWrapper
		self.mainOptions = mainOptions
		
		super.init()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
