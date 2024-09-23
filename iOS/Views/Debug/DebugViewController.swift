//
//  DebugViewController.swift
//  feather
//
//  Created by samara on 20.09.2024.
//

import Foundation
import SwiftUI
import UIKit

class DebugHostingController: UIHostingController<DebugViewController> {
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder, rootView: DebugViewController())
	}
	
	override init(rootView: DebugViewController) {
		super.init(rootView: rootView)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		navigationController?.navigationBar.prefersLargeTitles = true
		navigationItem.largeTitleDisplayMode = .always
	}
}

struct DebugViewController: View {
	
	var body: some View {
		List {
			
		}
		.onAppear {

		}
	}
}

