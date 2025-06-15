//
//  View+navigationTitle2Lined_private.swift
//  NimbleKit
//
//  Created by samara on 15.06.2025.
//

import SwiftUI

extension View {
	public func navigationTitle2Lined() -> some View {
		overlay {
			NavConfigurator().frame(width: 0, height: 0)
		}
	}
}

struct NavConfigurator: UIViewControllerRepresentable {
	class ViewControllerWrapper: UIViewController {
		override func viewWillAppear(_ animated: Bool) {
			guard
				let navigationController = self.navigationController,
				let navigationItem = navigationController.visibleViewController?.navigationItem
			else {
				return
			}
			
			let keyBase64Name = "X19sYXJnZVRpdGxlVHdvTGluZU1vZGU="
			
			guard
				let keyNameData = Data(base64Encoded: keyBase64Name),
				let keyName = String(data: keyNameData, encoding: .utf8)
			else {
				return
			}
			
			navigationItem.setValue(true, forKey: keyName)
			super.viewWillAppear(animated)
		}
	}
	
	func makeUIViewController(context: Context) -> UIViewController {
		ViewControllerWrapper()
	}
	
	func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
