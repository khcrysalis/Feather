//
//  SourceAppViewController.swift
//  feather
//
//  Created by samara on 5/22/24.
//

import Foundation
import UIKit
import Nuke
import AlertKit

class SourceAppViewController: UIViewController {
	
	var tableView: UITableView!
	
	var apps: [StoreApps] = [] {
		didSet {
			
		}
	}
	
	var name: String? {
		didSet {
			self.title = name
		}
	}
	
	private var progress: CGFloat = 0.0
	private var progressCell: AppTableViewCell?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupNavigation()
		setupViews()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(true)
	}
	
	fileprivate func setupViews() {
		self.tableView = UITableView(frame: .zero, style: .plain)
		self.tableView.translatesAutoresizingMaskIntoConstraints = false
		self.tableView.backgroundColor = UIColor(named: "Background")
		self.tableView.dataSource = self
		self.tableView.delegate = self
		self.tableView.register(AppTableViewCell.self, forCellReuseIdentifier: "CustomCell")

		
		self.view.addSubview(tableView)
		self.tableView.constraintCompletely(to: view)
	}
	
	fileprivate func setupNavigation() {
		self.navigationItem.largeTitleDisplayMode = .never
	}
}

extension SourceAppViewController: UITableViewDelegate, UITableViewDataSource{
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return apps.count }
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = AppTableViewCell(style: .subtitle, reuseIdentifier: "RoundedBackgroundCell")
		
		let app = apps[indexPath.row]
		cell.configure(with: app)
		cell.selectionStyle = .none
		cell.getButton.tag = indexPath.row
		cell.getButton.addTarget(self, action: #selector(getButtonTapped(_:)), for: .touchUpInside)
		
		SectionIcons.sectionImage(to: cell, with: UIImage(named: "unknown")!)
		
		if let thumbnailURL = app.iconURL {
			let request = ImageRequest(url: thumbnailURL)
			
			if let cachedImage = ImagePipeline.shared.cache.cachedImage(for: request)?.image {
				SectionIcons.sectionImage(to: cell, with: cachedImage)
			} else {
				ImagePipeline.shared.loadImage(
					with: request,
					progress: nil,
					completion: { result in
						switch result {
						case .success(let imageResponse):
							DispatchQueue.main.async {
								SectionIcons.sectionImage(to: cell, with: imageResponse.image)
								tableView.reloadRows(at: [indexPath], with: .fade)
							}
						case .failure(let error):
							print("Image loading failed with error: \(error)")
						}
					}
				)
			}
		}
		return cell
	}
	
}

extension SourceAppViewController: DownloadDelegate {

	func stopDownload() {
		DispatchQueue.main.async {
			self.progressCell!.stopDownload()
			self.progress = 0.0
			self.progressCell = nil
		}
	}
	
	func updateDownloadProgress(progress: Double) {
		print(progress)
		self.progress = CGFloat(Float(progress))
		DispatchQueue.main.async {
			self.progressCell?.updateProgress(to: self.progress)
		}
	
	}
	
	@objc func getButtonTapped(_ sender: UIButton) {
		let indexPath = IndexPath(row: sender.tag, section: 0)
		let app = apps[indexPath.row]
		
		// Uses old altstore app method still, does not support multiple versioning at this point!
		// sorry pyoncord users, will add this later :3
		
		if let downloadURL = app.downloadURL {
			//print("Download URL for app at \(indexPath): \(downloadURL)")
			
			if let cell = tableView.cellForRow(at: indexPath) as? AppTableViewCell {
				self.progressCell = cell
				progressCell!.startDownload()
				
				let appDownload = AppDownload()
				appDownload.dldelegate = self
				appDownload.downloadFile(url: downloadURL) { (filePath, error) in
					
					appDownload.extractFileAndAddToAppsTab(packageURL: filePath!) {(_, error) in
						
						if (error != nil) {
							print("dumb bitch")
						} else {
							self.meow()
						}
					}
				}
			}
		}
	}
	
	func meow() {
		DispatchQueue.main.async {
			let alertView = AlertAppleMusic17View(title: "Added to Apps (didnt really)", subtitle: nil, icon: .done)
			if let viewController = UIApplication.shared.keyWindow?.rootViewController {
				alertView.present(on: viewController.view)
			}
		}
	}
}

protocol DownloadDelegate: AnyObject {
	func updateDownloadProgress(progress: Double)
	func stopDownload()
}
