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
	
	let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
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
	private var progressCell: SourceAppTableViewCell?
	
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
		self.tableView.register(SourceAppTableViewCell.self, forCellReuseIdentifier: "CustomCell")

		
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
		let cell = SourceAppTableViewCell(style: .subtitle, reuseIdentifier: "RoundedBackgroundCell")
		
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
								tableView.reloadRows(at: [indexPath], with: .none)
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
			if let cell = tableView.cellForRow(at: indexPath) as? SourceAppTableViewCell {
				self.progressCell = cell
				progressCell!.startDownload()
				
				let appDownload = AppDownload()
				appDownload.dldelegate = self
				appDownload.downloadFile(url: downloadURL) { (uuid, filePath, error) in
					appDownload.extractCompressedBundle(packageURL: filePath!) {(targetBundle, error) in
						if (error != nil) {
							self.errorPopup()
						} else {
							self.addToApps(bundlePath: targetBundle ?? "", uuid: uuid!) {_ in
								self.successPopup()
							}
						}
					}
				}
				
			}
		}
		
	}
	
	func successPopup() {
		DispatchQueue.main.async {
			let alertView = AlertAppleMusic17View(title: "Added to Apps", subtitle: nil, icon: .done)
			if let viewController = UIApplication.shared.keyWindow?.rootViewController {
				alertView.present(on: viewController.view)
			}
		}
	}
	
	func errorPopup() {
		DispatchQueue.main.async {
			let alertView = AlertAppleMusic17View(title: "Error: mew!", subtitle: nil, icon: .error)
			if let viewController = UIApplication.shared.keyWindow?.rootViewController {
				alertView.present(on: viewController.view)
			}
		}
	}
	
	func addToApps(bundlePath: String, uuid: String, completion: @escaping (Error?) -> Void) {
		guard let bundle = Bundle(path: bundlePath) else {
			let error = NSError(domain: "Feather", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to load bundle at \(bundlePath)"])
			completion(error)
			return
		}
		let context = self.context
		let newApp = DownloadedApps(context: context)
		
		if let infoDict = bundle.infoDictionary {
			if let version = infoDict["CFBundleShortVersionString"] as? String {
				newApp.version = version
			}
			
			if let appName = infoDict["CFBundleDisplayName"] as? String {
				newApp.name = appName
			} else if let appName = infoDict["CFBundleName"] as? String {
				newApp.name = appName
			}
			
			if let bundleIdentifier = infoDict["CFBundleIdentifier"] as? String {
				newApp.bundleidentifier = bundleIdentifier
			}
			
			if let iconsDict = infoDict["CFBundleIcons"] as? [String: Any],
			   let primaryIconsDict = iconsDict["CFBundlePrimaryIcon"] as? [String: Any],
			   let iconFiles = primaryIconsDict["CFBundleIconFiles"] as? [String],
			   let iconFileName = iconFiles.first,
			   let iconPath = bundle.path(forResource: iconFileName+"@2x", ofType: "png") {
				newApp.iconURL = "\(URL(string: iconPath)?.lastPathComponent ?? "")"
			} else {
				print("Failed to retrieve app icon path")
			}
			
			newApp.uuid = uuid
			
			newApp.appPath = "\(URL(string: bundlePath)?.lastPathComponent ?? "")"
			
			do {
				try context.save()
			} catch {
				print("Error saving data: \(error)")
			}
			
			completion(nil)
		} else {
			let error = NSError(domain: "Feather", code: 3, userInfo: [NSLocalizedDescriptionKey: "Info.plist not found in bundle at \(bundlePath)"])
			completion(error)
		}
	}


	
}

protocol DownloadDelegate: AnyObject {
	func updateDownloadProgress(progress: Double)
	func stopDownload()
}
