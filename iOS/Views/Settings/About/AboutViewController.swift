//
//  AboutViewController.swift
//  feather
//
//  Created by samara on 7/10/24.
//  Copyright (c) 2024 Samara M (khcrysalis)
//

import UIKit
import MachO

class AboutViewController: FRSTableViewController {
	var credits: [CreditsPerson] = []
	var creditsSponsors: [CreditsPerson] = []
	var fileNames: [String] = []
	
	private let sourceGET = SourceGET()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		tableData = [
			["Header"],
			[],
			["", "Thanks"], // Don't translate this
			[]
		]
		
		sectionTitles = [
			"",
			String.localized("ABOUT_VIEW_CONTROLLER_SECTION_TITLE_CREDITS"),
			String.localized("ABOUT_VIEW_CONTROLLER_SECTION_TITLE_SPONSORS"),
			String.localized("ABOUT_VIEW_CONTROLLER_SECTION_TITLE_ACKNOWLEDGEMENTS")
		]
		
		setupCreditsSection()
		setupNavigation()
	}
	
	fileprivate func setupNavigation() {
		self.title = "About"
		self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareButtonTapped))
	}
	
	fileprivate func setupCreditsSection() {
		if let mdFiles = try? FileManager.default.contentsOfDirectory(atPath: Bundle.main.bundlePath).filter({ $0.hasSuffix(".md") }) {
			fileNames = mdFiles
			tableData[3] = fileNames
		}
		
		let creditsURL = URL(string: "https://raw.githubusercontent.com/khcrysalis/project-credits/refs/heads/main/feather/credits.json")!
		let sponsorsURL = URL(string: "https://raw.githubusercontent.com/khcrysalis/project-credits/refs/heads/main/sponsors/credits.json")!
		
		getURL(url: creditsURL) { result in
			switch result {
			case .success(let credits):
				self.credits = credits
				self.tableData[1] = credits.map { $0.name ?? "" }
				DispatchQueue.main.async {
					self.tableView.reloadSections(IndexSet(integer: 1), with: .automatic)
				}
			case .failure(_):
				Debug.shared.log(message: "Error fetching credits")
			}
		}
		
		getURL(url: sponsorsURL) { result in
			switch result {
			case .success(let sponsors):
				self.creditsSponsors = sponsors
				DispatchQueue.main.async {
					self.tableView.reloadSections(IndexSet(integer: 2), with: .automatic)
				}
			case .failure(_):
				Debug.shared.log(message: "Error fetching sponsors")
			}
		}
	}
	
	private func getURL(url: URL, completion: @escaping (Result<[CreditsPerson], Error>) -> Void) {
		sourceGET.downloadURL(from: url) { result in
			switch result {
			case .success((let data, _)):
				switch SourceGET().parsec(data: data) {
				case .success(let sourceData):
					completion(.success(sourceData))
				case .failure(let error):
					Debug.shared.log(message: "Error parsing data: \(error)")
					completion(.failure(error))
				}
			case .failure(let error):
				Debug.shared.log(message: "Error downloading data: \(error)")
				completion(.failure(error))
			}
		}
	}

	
	@objc func shareButtonTapped() {
		let shareText = "Feather - https://github.com/khcrysalis/feather"
		let activityViewController = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
		
		if let popoverController = activityViewController.popoverPresentationController {
			popoverController.sourceView = self.view
			popoverController.sourceRect = self.view.bounds
			popoverController.permittedArrowDirections = []
		}
		
		present(activityViewController, animated: true, completion: nil)
	}
}

extension AboutViewController {
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let reuseIdentifier = "Cell"
		let cell = UITableViewCell(style: .value1, reuseIdentifier: reuseIdentifier)
		cell.accessoryType = .none
		cell.selectionStyle = .none
		
		let cellText = tableData[indexPath.section][indexPath.row]
		
		switch indexPath.section {
		case 0:
			let cell = HeaderTableViewCell()
			let appName = Bundle.main.infoDictionary?["CFBundleName"] as? String ?? ""
			let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
			let buildVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
			let versionString = "Version \(appVersion) (Build \(buildVersion))"
			cell.backgroundColor = .clear
			cell.selectionStyle = .none
			cell.configure(withTitle: appName, versionString: versionString)
			return cell
		case 1:
			
			let personCellIdentifier = "PersonCell"
			let personCell = tableView.dequeueReusableCell(withIdentifier: personCellIdentifier) as? PersonCell ?? PersonCell(style: .default, reuseIdentifier: personCellIdentifier)
			
			let credits = self.credits[indexPath.row]
			
			personCell.configure(with: credits)
			if let arrowImage = UIImage(systemName: "arrow.up.forward")?.withTintColor(UIColor.tertiaryLabel, renderingMode: .alwaysOriginal) {
				personCell.accessoryView = UIImageView(image: arrowImage)
			}
			return personCell
		case 2:
			if cellText != "Thanks" {
				let personCellIdentifier = "BatchPersonCell"
				let personCell = tableView.dequeueReusableCell(withIdentifier: personCellIdentifier) as? BatchPersonCell ?? BatchPersonCell(style: .default, reuseIdentifier: personCellIdentifier)
							
				personCell.configure(with: creditsSponsors)
				return personCell
			} else {
				// Don't translate this
				cell.textLabel?.text = "💙 This couldn't of been done without my sponsors!"
				cell.textLabel?.textColor = .secondaryLabel
				cell.textLabel?.numberOfLines = 0
				return cell
			}
		case 3:
			let cell = UITableViewCell(style: .default, reuseIdentifier: reuseIdentifier)
			cell.textLabel?.text = cellText
			cell.accessoryType = .disclosureIndicator
			return cell
		default:
			break
		}

		
		return cell
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let selectedFileName = tableData[indexPath.section][indexPath.row]
		switch indexPath.section {
		case 1:
			let developer =  self.credits[indexPath.row]
			if let socialLink = URL(string: "https://github.com/\(developer.github)") {
				UIApplication.shared.open(socialLink, options: [:], completionHandler: nil)
			}
		case 3:
			if let fileContents = loadFileContents(fileName: selectedFileName) {
				let textViewController = LicenseViewController()
				textViewController.textContent = fileContents
				textViewController.titleText = selectedFileName
				navigationController?.pushViewController(textViewController, animated: true)
			}
		default:
			break
		}
		
		tableView.deselectRow(at: indexPath, animated: true)
	}
}

extension AboutViewController {
	private func loadFileContents(fileName: String) -> String? {
		guard let filePath = Bundle.main.path(forResource: fileName, ofType: ""),
			  let fileContents = try? String(contentsOfFile: filePath) else {
			return nil
		}
		return fileContents
	}
}
