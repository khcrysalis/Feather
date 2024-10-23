//
//  PreferredLanguageViewController.swift
//  Antoine
//
//  Created by Serena on 24/02/2023.
//  Code from: https://github.com/NSAntoine/Antoine/blob/main/Antoine/UI/PreferredLanguageViewController.swift
//

/*
 MIT License

 Copyright (c) 2024 Antoine

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */

import UIKit

class PreferredLanguageViewController: UITableViewController {
	lazy var languages = Language.availableLanguages
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		title = String.localized("Language")
		self.navigationItem.largeTitleDisplayMode = .never
		tableView = UITableView(frame: tableView.frame, style: .insetGrouped)
	}
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return Preferences.preferredLanguageCode != nil ? 2 : 1
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch section {
		case 0:
			return 1
		case 1:
			return languages.count
		default:
			fatalError()
		}
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell: UITableViewCell
		
		if (indexPath.section, indexPath.row) == (0, 0) {
			cell = UITableViewCell()
			cell.textLabel?.text = String.localized("Use System Language")
			let uiSwitch = UISwitch()
			uiSwitch.isOn = Preferences.preferredLanguageCode == nil
			uiSwitch.addTarget(self, action: #selector(useSystemLanguageToggled(sender:)), for: .valueChanged)
			cell.accessoryView = uiSwitch
		} else {
			cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
			let lang = languages[indexPath.row]
			cell.accessoryType = Preferences.preferredLanguageCode == lang.languageCode ? .checkmark : .none
			cell.textLabel?.text = lang.displayName
			cell.detailTextLabel?.text = lang.subtitleText
			cell.detailTextLabel?.textColor = .secondaryLabel
		}
		
		return cell
	}
	
	override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
		return indexPath.section == 1
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		guard indexPath.section == 1 else { return }
		let languageSelected = languages[indexPath.row]
		Preferences.preferredLanguageCode = languageSelected.languageCode
		tableView.reloadSections([1], with: .automatic)
		
		let alert = UIAlertController(
			title: String.localized("Restart Application for changes to fully apply"),
			message: nil,
			preferredStyle: .alert
		)
		alert.addAction(.init(title: "OK", style: .default))
		present(alert, animated: true)
	}
	
	@objc func useSystemLanguageToggled(sender: UISwitch) {
		if sender.isOn {
			UserDefaults.standard.set(nil, forKey: "UserPreferredLanguageCode")
			Bundle.preferredLocalizationBundle = .makeLocalizationBundle()
			tableView.deleteSections([1], with: .automatic)
		} else {
			Preferences.preferredLanguageCode = Locale.current.languageCode
			tableView.insertSections([1], with: .automatic)
		}
	}
}
