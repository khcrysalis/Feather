//
//  ThemedTableViewController.swift
//  Feather
//
//  Created by samsam on 5/24/26.
//

import UIKit

class ThemedTableViewController: UITableViewController {
	init() {
		#if os(iOS)
		super.init(style: .insetGrouped)
		#else
		super.init(style: .grouped)
		#endif
	}
	
	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	open override func viewDidLoad() {
		super.viewDidLoad()
		#if os(iOS)
		self._configureTitleDisplayMode()
		#endif
		tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
	}
	
	#if os(iOS)
	private func _configureTitleDisplayMode() {
		if navigationController?.viewControllers.first === self {
			navigationItem.largeTitleDisplayMode = .always
			navigationController?.navigationBar.prefersLargeTitles = true
		} else {
			navigationItem.largeTitleDisplayMode = .never
		}
	}
	#endif
}
