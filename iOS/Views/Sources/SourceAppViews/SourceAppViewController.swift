//
//  SourceAppViewController.swift
//  feather
//
//  Created by samara on 5/22/24.
//

import UIKit
import Nuke
import AlertKit
import CoreData

class SourceAppViewController: UITableViewController {
	var apps: [StoreAppsData] = []
	var name: String? { didSet { self.title = name } }
	var uri: URL!
	
	var highlightAppName: String?
	var highlightBundleID: String?
	var highlightDeveloperName: String?
	
	private let sourceGET = SourceGET()
	
	private let activityIndicator: UIActivityIndicatorView = {
		let indicator = UIActivityIndicatorView(style: .medium)
		indicator.hidesWhenStopped = true
		return indicator
	}()
	
	init() { super.init(style: .plain) }
	required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupNavigation()
		setupViews()
		loadAppsData()
	}
	
	fileprivate func setupViews() {
		self.tableView.dataSource = self
		self.tableView.delegate = self
		self.tableView.tableHeaderView = UIView()
		self.tableView.register(AppTableViewCell.self, forCellReuseIdentifier: "AppTableViewCell")
		
		let barButton = UIBarButtonItem(customView: activityIndicator)
		self.navigationItem.setRightBarButton(barButton, animated: true)
		self.activityIndicator.startAnimating()
	}
	
	fileprivate func setupNavigation() {
		self.navigationItem.largeTitleDisplayMode = .never
	}
	
	private func loadAppsData() {
		guard let uri = uri else { return }
		sourceGET.downloadURL(from: uri) { [weak self] result in
			switch result {
			case .success(let (data, _)):
				let parseResult = self?.sourceGET.parse(data: data)
				switch parseResult {
				case .success(let sourceData):
					DispatchQueue.main.async {
						self?.apps = sourceData.apps
						
						if let fil = self?.shouldFilter() {
							self?.apps = [fil].compactMap { $0 }
						}
						
						UIView.transition(with: self!.tableView, duration: 0.3, options: .transitionCrossDissolve, animations: {
							self!.activityIndicator.stopAnimating()
							self?.tableView.reloadData()
						}, completion: nil)
					}
				case .failure(let error):
					print("Error parsing data: \(error.localizedDescription)")
				case .none:
					break
				}
				
			case .failure(let error):
				print("Error fetching data: \(error.localizedDescription)")
			}
		}
	}
	
	private func shouldFilter() -> StoreAppsData? {
		guard
			let name = highlightAppName,
			let id = highlightBundleID
		else {
			print("did we filter? no")
			return nil
		}
		
		return filterApps(from: apps, name: name, id: id, devname: highlightDeveloperName).first
	}

	private func filterApps(from apps: [StoreAppsData], name: String, id: String, devname: String?) -> [StoreAppsData] {
		print("did we filter? yes")
		return apps.filter { app in
			return app.name == name && app.bundleIdentifier == id && (devname == nil || app.developerName == devname)
		}
	}

}

extension SourceAppViewController {
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return apps.count
	}
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		
		let app = apps[indexPath.row]
		if (app.screenshotURLs != nil), !app.screenshotURLs!.isEmpty {
			return 322
		} else {
			return 72
		}
	}

	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = AppTableViewCell(style: .subtitle, reuseIdentifier: "RoundedBackgroundCell")
		let app = apps[indexPath.row]
		cell.configure(with: app)
		cell.selectionStyle = .none
		cell.backgroundColor = .clear
		cell.getButton.tag = indexPath.row
		cell.getButton.addTarget(self, action: #selector(getButtonTapped(_:)), for: .touchUpInside)
		let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(getButtonHold(_:)))
		cell.getButton.addGestureRecognizer(longPressGesture)
		cell.getButton.longPressGestureRecognizer = longPressGesture
		return cell
	}
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		if apps.isEmpty || (highlightAppName != nil) {
			return nil
		} else {
			return "\(apps.count) Apps"
		}
	}
}
