//
//  ChangelogViewController.swift
//  barracuta
//
//  Created by samara on 1/14/24.
//  Copyright © 2024 samiiau. All rights reserved.
//

import UIKit
import SafariServices
import Markdown

struct Release: Decodable {
	let name: String
	let body: String
	let html_url: String
}

class ReleaseCell: UITableViewCell {
	
	let bodyLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.numberOfLines = 0
		label.font = UIFont.systemFont(ofSize: 14)
		return label
	}()
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		
		addSubview(bodyLabel)
		
		NSLayoutConstraint.activate([
			bodyLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
			bodyLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
			bodyLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
			bodyLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
		])
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

class ChangelogViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
	
	var tableView: UITableView!
	var releases: [[Release]] = []
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.title = "Changelogs"
		self.navigationItem.largeTitleDisplayMode = .never
		tableView = UITableView(frame: .zero, style: .insetGrouped)
		tableView.dataSource = self
		tableView.delegate = self
		view.addSubview(tableView)
		
		tableView.register(ReleaseCell.self, forCellReuseIdentifier: "ReleaseCell")
		
		tableView.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			tableView.topAnchor.constraint(equalTo: view.topAnchor),
			tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
		])
		
		fetchReleases()
	}
	
	func fetchReleases() {
		if let url = URL(string: "https://api.github.com/repos/khcrysalis/Feather/releases") {
			URLSession.shared.dataTask(with: url) { data, _, error in
				if let data = data {
					do {
						let decoder = JSONDecoder()
						let allReleases = try decoder.decode([Release].self, from: data)
						
						let groupedReleases = Dictionary(grouping: allReleases, by: { $0.name })
						self.releases = groupedReleases.values.sorted(by: { $0[0].name > $1[0].name })
						
						DispatchQueue.main.async {
							self.tableView.reloadData()
						}
					} catch {
						print("Error decoding JSON: \(error.localizedDescription)")
					}
				}
			}.resume()
		}
	}
	
	func numberOfSections(in tableView: UITableView) -> Int { return releases.count }
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return releases[section].count }
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? { return releases[section][0].name }
	
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		let sectionTitle = releases[section][0].name
		if sectionTitle.isEmpty { return 0 }
		return 40
	}
	
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let title = releases[section][0].name
		let headerView = GroupedSectionHeader(title: title)
		return headerView
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "ReleaseCell", for: indexPath) as! ReleaseCell
		let release = releases[indexPath.section][indexPath.row]
		var markdownosaur = Markdownosaur()
		let document = Document(parsing: release.body)
		
		cell.bodyLabel.attributedText = markdownosaur.attributedString(from: document)
		
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let release = releases[indexPath.section][indexPath.row]
		
		if let url = URL(string: release.html_url) {
			let safariVC = SFSafariViewController(url: url)
			present(safariVC, animated: true, completion: nil)
		}
		
		tableView.deselectRow(at: indexPath, animated: true)
	}
}
