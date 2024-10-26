//
//  SigningViewHostingController.swift
//  feather
//
//  Created by samara on 25.10.2024.
//

import SwiftUI

class SigningViewHostingController: UIHostingController<SigningView> {
	private var signingDataWrapper = SigningDataWrapper(signingOptions: UserDefaults.standard.signingOptions)

	init() {
		super.init(rootView: SigningView(sign: false, signingDataWrapper: signingDataWrapper))
	}

	@objc required dynamic init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		self.navigationItem.largeTitleDisplayMode = .never
		self.title = "Signing Options"
		self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(save))
	}

	@objc func save() {
		UserDefaults.standard.signingOptions = signingDataWrapper.signingOptions
	}
}
