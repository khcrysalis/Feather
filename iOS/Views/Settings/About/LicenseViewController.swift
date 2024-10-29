//
//  LicenseViewController.swift
//  feather
//
//  Created by samara on 28.10.2024.
//

import UIKit

class LicenseViewController: UIViewController {
	
	var textContent: String?
	var titleText: String?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		title = titleText
		let textView = UITextView()
		textView.text = textContent
		textView.isEditable = false
		textView.translatesAutoresizingMaskIntoConstraints = false
		
		let monospacedFont = UIFont.monospacedSystemFont(ofSize: 12.0, weight: .regular)
		textView.font = monospacedFont
		
		// Scroll to top
		textView.setContentOffset(CGPoint.zero, animated: true)
		textView.contentInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)

		view.addSubview(textView)
		
		NSLayoutConstraint.activate([
			textView.topAnchor.constraint(equalTo: view.topAnchor),
			textView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			textView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			textView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
		])
	}
}

