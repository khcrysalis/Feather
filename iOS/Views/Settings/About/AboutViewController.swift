//
//  AboutViewController.swift
//  feather
//
//  Created by samara on 7/10/24.
//  Copyright (c) 2024 Samara M (khcrysalis)
//

import UIKit
import MachO

class AboutViewController: UITableViewController {
	let tintColor = Preferences.appTintColor.uiColor
	var fileNames: [String] = []
	var tableData =
	[
		["Header"],
		[],
		[String.localized("ABOUT_VIEW_CONTROLLER_CELL_DEVICE_VERSION"), String.localized("ABOUT_VIEW_CONTROLLER_CELL_DEVICE_ARCH"), String.localized("ABOUT_VIEW_CONTROLLER_CELL_APP_VERSION")],
		[]
	]
	
	var sectionTitles =
	[
		"",
		String.localized("ABOUT_VIEW_CONTROLLER_SECTION_TITLE_CREDITS"),
		String.localized("ABOUT_VIEW_CONTROLLER_SECTION_TITLE_DEVICE"),
		String.localized("ABOUT_VIEW_CONTROLLER_SECTION_TITLE_ACKNOWLEDGEMENTS")
	]
	
	init() { super.init(style: .insetGrouped) }
	required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(false)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupViews()
		setupCreditsSection()
		setupNavigation()
	}
	
	fileprivate func setupViews() {
		self.tableView.dataSource = self
		self.tableView.delegate = self
	}
	
	@objc func shareButtonTapped() {
		let shareText = "Feather - https://github.com/khcrysalis/feather"
		let activityViewController = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
		present(activityViewController, animated: true, completion: nil)
	}
	
	fileprivate func setupNavigation() {
		self.title = "About"
		self.navigationItem.largeTitleDisplayMode = .never
		self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareButtonTapped))
	}
	
	fileprivate func setupCreditsSection() {
		if let mdFiles = try? FileManager.default.contentsOfDirectory(atPath: Bundle.main.bundlePath).filter({ $0.hasSuffix(".md") }) {
			fileNames = mdFiles
			tableData[3] = fileNames
		}
		
		let credits = CreditsData.getCreditsData()
		var creditsSection: [String] = []
		
		for _ in credits {
			creditsSection.append("Credits Person")
		}
		
		tableData[1] = creditsSection
	}
}

extension AboutViewController {
	override func numberOfSections(in tableView: UITableView) -> Int { return sectionTitles.count }
	override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat { return sectionTitles[section].isEmpty ? 0 : 40 }
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return tableData[section].count }
	
	override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let title = sectionTitles[section]
		let headerView = InsetGroupedSectionHeader(title: title)
		return headerView
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let reuseIdentifier = "Cell"
		let cell = UITableViewCell(style: .value1, reuseIdentifier: reuseIdentifier)
		cell.accessoryType = .none
		cell.selectionStyle = .none
		
		let cellText = tableData[indexPath.section][indexPath.row]
		cell.textLabel?.text = cellText
		
		switch cellText {
		case "Header":
			let cell = HeaderTableViewCell()
			let appName = Bundle.main.infoDictionary?["CFBundleName"] as? String ?? ""
			let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
			let buildVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
			let versionString = "Version \(appVersion) (Build \(buildVersion))"
			cell.backgroundColor = .clear
			cell.selectionStyle = .none
			cell.configure(withTitle: appName, versionString: versionString)
			return cell
		case String.localized("ABOUT_VIEW_CONTROLLER_CELL_DEVICE_VERSION"):
			cell.detailTextLabel?.text = UIDevice.current.systemVersion
		case String.localized("ABOUT_VIEW_CONTROLLER_CELL_DEVICE_ARCH"):
			cell.detailTextLabel?.text = String(cString: NXGetLocalArchInfo().pointee.name)
		case String.localized("ABOUT_VIEW_CONTROLLER_CELL_APP_VERSION"):
			guard let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else {
				break
			}
			cell.detailTextLabel?.text = appVersion
		case "Build":
			break
		default:
			break
		}
		
		if sectionTitles[indexPath.section] == String.localized("ABOUT_VIEW_CONTROLLER_SECTION_TITLE_CREDITS") {
			let personCellIdentifier = "PersonCell"
			let personCell = tableView.dequeueReusableCell(withIdentifier: personCellIdentifier) as? PersonCell ?? PersonCell(style: .default, reuseIdentifier: personCellIdentifier)
						
			let developers = CreditsData.getCreditsData()
			let developer = developers[indexPath.row]
			
			personCell.configure(with: developer)
			if let arrowImage = UIImage(systemName: "arrow.up.forward")?.withTintColor(UIColor.tertiaryLabel, renderingMode: .alwaysOriginal) {
				personCell.accessoryView = UIImageView(image: arrowImage)
			}
			return personCell
		}
		
		if sectionTitles[indexPath.section] == String.localized("ABOUT_VIEW_CONTROLLER_SECTION_TITLE_ACKNOWLEDGEMENTS") {
			let cell = UITableViewCell(style: .default, reuseIdentifier: reuseIdentifier)
			cell.textLabel?.text = cellText
			cell.accessoryType = .disclosureIndicator
			return cell
		}
		
		return cell
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if sectionTitles[indexPath.section] == String.localized("ABOUT_VIEW_CONTROLLER_SECTION_TITLE_CREDITS") {
			let developers = CreditsData.getCreditsData()
			let developer = developers[indexPath.row]
			if let socialLink = developer.socialLink {
				UIApplication.shared.open(socialLink, options: [:], completionHandler: nil)
			}
		}
		
		let selectedFileName = tableData[indexPath.section][indexPath.row]
		
		if sectionTitles[indexPath.section] == String.localized("ABOUT_VIEW_CONTROLLER_SECTION_TITLE_ACKNOWLEDGEMENTS") {
			if let fileContents = loadFileContents(fileName: selectedFileName) {
				let textViewController = TextViewController()
				textViewController.textContent = fileContents
				textViewController.titleText = selectedFileName
				navigationController?.pushViewController(textViewController, animated: true)
			}
		}
		tableView.deselectRow(at: indexPath, animated: true)
	}
	
	private func loadFileContents(fileName: String) -> String? {
		guard let filePath = Bundle.main.path(forResource: fileName, ofType: ""),
			  let fileContents = try? String(contentsOfFile: filePath) else {
			return nil
		}
		return fileContents
	}
	
}

class TextViewController: UIViewController {
	
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

