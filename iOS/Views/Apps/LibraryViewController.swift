//
//  LibraryViewController.swift
//  feather
//
//  Created by samara on 8/12/24.
//

import Foundation
import CoreData
import UniformTypeIdentifiers
import MBProgressHUD

class LibraryViewController: UITableViewController {
	var signedApps: [SignedApps]?
	var downloadedApps: [DownloadedApps]?
	
	var filteredSignedApps: [SignedApps] = []
	var filteredDownloadedApps: [DownloadedApps] = []
	
	public var searchController: UISearchController!
	var popupVC: PopupViewController!
	
	init() { super.init(style: .grouped) }
	required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupViews()
		setupSearchController()
		fetchSources()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		setupNavigation()
	}
	
	fileprivate func setupViews() {
		self.tableView.dataSource = self
		self.tableView.delegate = self
		self.tableView.backgroundColor = .background
		tableView.register(AppsTableViewCell.self, forCellReuseIdentifier: "RoundedBackgroundCell")
		NotificationCenter.default.addObserver(self, selector: #selector(afetch), name: Notification.Name("lfetch"), object: nil)
		
	}
	
	deinit {
		NotificationCenter.default.removeObserver(self, name: Notification.Name("lfetch"), object: nil)
	}
	
	fileprivate func setupNavigation() {
		self.navigationController?.navigationBar.prefersLargeTitles = true
	}
}

extension LibraryViewController {
	override func numberOfSections(in tableView: UITableView) -> Int { return 2 }
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch section {
		case 0:
			return isFiltering ? filteredSignedApps.count : signedApps?.count ?? 0
		case 1:
			return isFiltering ? filteredDownloadedApps.count : downloadedApps?.count ?? 0
		default:
			return 0
		}
	}
	
	override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		switch section {
		case 0:
			let headerWithButton = GroupedSectionHeader(title: "Signed Apps", subtitle: "\(signedApps?.count ?? 0) Signed", buttonTitle: "Import", buttonAction: {
				self.beginImportFile()
			})
			return headerWithButton
		case 1:
			let headerWithButton = GroupedSectionHeader(title: "Downloaded Apps")
			return headerWithButton
		default:
			return nil
		}
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = AppsTableViewCell(style: .subtitle, reuseIdentifier: "RoundedBackgroundCell")
		cell.selectionStyle = .default
		cell.accessoryType = .disclosureIndicator
		cell.backgroundColor = .clear
		let source = getApplication(row: indexPath.row, section: indexPath.section)
		let filePath = getApplicationFilePath(with: source!, row: indexPath.row, section: indexPath.section)
		
		
		if let iconURL = source!.value(forKey: "iconURL") as? String {
			let imagePath = filePath!.appendingPathComponent(iconURL)
			
			if let image = CoreDataManager.shared.loadImage(from: imagePath) {
				SectionIcons.sectionImage(to: cell, with: image)
			} else {
				SectionIcons.sectionImage(to: cell, with: UIImage(named: "unknown")!)
			}
		} else {
			SectionIcons.sectionImage(to: cell, with: UIImage(named: "unknown")!)
		}
		
		cell.configure(with: source!, filePath: filePath!)
		return cell
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let source = getApplication(row: indexPath.row, section: indexPath.section)
		let filePath = getApplicationFilePath(with: source!, row: indexPath.row, section: indexPath.section, getuuidonly: true)
		let filePath2 = getApplicationFilePath(with: source!, row: indexPath.row, section: indexPath.section, getuuidonly: false)
		
		switch indexPath.section {
		case 0:
			if FileManager.default.fileExists(atPath: filePath2!.path) {
				popupVC = PopupViewController()
				popupVC.modalPresentationStyle = .pageSheet
				
				let button1 = PopupViewControllerButton(title: "Install \((source!.value(forKey: "name") as? String ?? ""))", color: .tintColor.withAlphaComponent(0.9))
				button1.onTap = { [weak self] in
					guard let self = self else { return }
					self.startInstallProcess(meow: source!, filePath: filePath?.path ?? "")
				}
				let button3 = PopupViewControllerButton(title: "Resign \((source!.value(forKey: "name") as? String ?? ""))", color: .quaternarySystemFill, titleColor: .tintColor)
				button3.onTap = { [weak self] in
					guard let self = self else { return }
					self.popupVC.dismiss(animated: true)
					MBProgressHUD.showAdded(to: self.view, animated: true)
					let cert = CoreDataManager.shared.getCurrentCertificate()!
					
					resignApp(certificate: cert, appPath: filePath2!) { success in
						if success {
							CoreDataManager.shared.updateSignedApp(app: source as! SignedApps, newTimeToLive: (cert.certData?.expirationDate)!, newTeamName: (cert.certData?.name)!) { _ in
								DispatchQueue.main.async {
									MBProgressHUD.hide(for: self.view, animated: true)
									Debug.shared.log(message: "Done action??")
									self.tableView.reloadRows(at: [indexPath], with: .left)
								}
							}
						}
					}
				}
				
				let button2 = PopupViewControllerButton(title: "Share \((source!.value(forKey: "name") as? String ?? ""))", color: .quaternarySystemFill, titleColor: .tintColor)
				button2.onTap = { [weak self] in
					guard let self = self else { return }
					self.shareFile(meow: source!, filePath: filePath?.path ?? "")
				}
				popupVC.configureButtons([button1, button3, button2])
				
				let detent2: UISheetPresentationController.Detent = ._detent(withIdentifier: "Test2", constant: 210.0)
				if let presentationController = popupVC.presentationController as? UISheetPresentationController {
					presentationController.detents = [
						detent2,
						.medium(),
						
					]
					presentationController.prefersGrabberVisible = true
				}
				
				self.present(popupVC, animated: true)
			} else {
				Debug.shared.log(message: "The file has been deleted for this entry, please remove it manually.", type: .critical)
			}
		case 1:
			if FileManager.default.fileExists(atPath: filePath2!.path) {
				popupVC = PopupViewController()
				popupVC.modalPresentationStyle = .pageSheet
				
				let button1 = PopupViewControllerButton(title: "Sign \((source!.value(forKey: "name") as? String ?? ""))", color: .tintColor.withAlphaComponent(0.9))
				button1.onTap = { [weak self] in
					guard let self = self else { return }
					self.startSigning(meow: source!)
				}
				
				popupVC.configureButtons([button1])
				
				let detent2: UISheetPresentationController.Detent = ._detent(withIdentifier: "Test2", constant: 110.0)
				if let presentationController = popupVC.presentationController as? UISheetPresentationController {
					presentationController.detents = [
						detent2,
						.medium(),
						
					]
					presentationController.prefersGrabberVisible = true
				}
				
				self.present(popupVC, animated: true)
			} else {
				Debug.shared.log(message: "The file has been deleted for this entry, please remove it manually.", type: .critical)
			}
		default:
			break
		}
		
		tableView.deselectRow(at: indexPath, animated: true)
	}
	
	@objc func startSigning(meow: NSManagedObject) {
		popupVC.dismiss(animated: true)
		if FileManager.default.fileExists(atPath: CoreDataManager.shared.getFilesForDownloadedApps(for:(meow as! DownloadedApps)).path) {
			let ap = AppSigningViewController(app: meow, appsViewController: self)
			let navigationController = UINavigationController(rootViewController: ap)
			navigationController.modalPresentationStyle = .formSheet
			self.present(navigationController, animated: true, completion: nil)
		}
	}
	
	override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		let source = getApplication(row: indexPath.row, section: indexPath.section)
		
		let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completionHandler) in
			switch indexPath.section {
			case 0:
				CoreDataManager.shared.deleteAllSignedAppContent(for: source! as! SignedApps)
				self.signedApps?.remove(at: indexPath.row)
				self.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
			case 1:
				CoreDataManager.shared.deleteAllDownloadedAppContent(for: source! as! DownloadedApps)
				self.downloadedApps?.remove(at: indexPath.row)
				self.tableView.reloadSections(IndexSet(integer: 1), with: .automatic)
			default:
				break
			}
			completionHandler(true)
		}
		
		deleteAction.backgroundColor = UIColor.red
		let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
		configuration.performsFirstActionWithFullSwipe = true

		return configuration
	}
	
	override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		let source = getApplication(row: indexPath.row, section: indexPath.section)
		let filePath = getApplicationFilePath(with: source!, row: indexPath.row, section: indexPath.section)
		
		let configuration = UIContextMenuConfiguration(identifier: nil, actionProvider: { _ in
			return UIMenu(title: "", image: nil, identifier: nil, options: [], children: [
				UIAction(title: "View Details", image: UIImage(systemName: "info.circle"), handler: {_ in
										
					let viewController = AppsInformationViewController()
					viewController.source = source
					viewController.filePath = filePath
					let navigationController = UINavigationController(rootViewController: viewController)
					
					if #available(iOS 15.0, *) {
						if let presentationController = navigationController.presentationController as? UISheetPresentationController {
							presentationController.detents = [.medium(), .large()]
						}
					}
					
					self.present(navigationController, animated: true)
					

				}),
				
				UIAction(title: "Open in Files", image: UIImage(systemName: "folder"), handler: {_ in
					
					let path = filePath?.deletingLastPathComponent()
					let path2 = path?.absoluteString.replacingOccurrences(of: "file://", with: "shareddocuments://")
					
					UIApplication.shared.open(URL(string: path2 ?? "")!, options: [:]) { success in
						if success {
							Debug.shared.log(message: "File opened successfully.")
						} else {
							Debug.shared.log(message: "Failed to open file.")
						}
					}
				})
				
			])
		})
		return configuration
	}
	
	
}

extension LibraryViewController {
	@objc func afetch() { self.fetchSources() }
	
	func fetchSources() {
		signedApps = CoreDataManager.shared.getDatedSignedApps()
		downloadedApps = CoreDataManager.shared.getDatedDownloadedApps()
		
		DispatchQueue.main.async {
			UIView.animate(withDuration: 0.1) {
				self.tableView.reloadData()
			}
		}
	}
	
	func getApplicationFilePath(with app: NSManagedObject, row: Int, section:Int, getuuidonly: Bool = false) -> URL? {
		if section == 0 {
			guard let source = getApplication(row: row, section: section) as? SignedApps else {
				return URL(string: "")!
			}
			return CoreDataManager.shared.getFilesForSignedApps(for: source, getuuidonly: getuuidonly)
		}
		
		if section == 1 {
			guard let source = getApplication(row: row, section: section) as? DownloadedApps else {
				return URL(string: "")!
			}
			return CoreDataManager.shared.getFilesForDownloadedApps(for: source, getuuidonly: getuuidonly)
		}
		return nil
	}
	
	func getApplication(row: Int, section: Int) -> NSManagedObject? {
		if isFiltering {
			if section == 0 {
				if row < filteredSignedApps.count {
					return filteredSignedApps[row]
				}
			} else if section == 1 {
				if row < filteredDownloadedApps.count {
					return filteredDownloadedApps[row]
				}
			}
		} else {
			if section == 0 {
				if row < signedApps?.count ?? 0 {
					return signedApps?[row]
				}
			} else if section == 1 {
				if row < downloadedApps?.count ?? 0 {
					return downloadedApps?[row]
				}
			}
		}
		return nil
	}

}

extension LibraryViewController: UISearchResultsUpdating {
	func updateSearchResults(for searchController: UISearchController) {
		let searchText = searchController.searchBar.text ?? ""
		filterContentForSearchText(searchText)
		tableView.reloadData()
	}
	
	private func filterContentForSearchText(_ searchText: String) {
		let lowercasedSearchText = searchText.lowercased()

		filteredSignedApps = signedApps?.filter { app in
			let name = (app.value(forKey: "name") as? String ?? "").lowercased()
			return name.contains(lowercasedSearchText)
		} ?? []

		filteredDownloadedApps = downloadedApps?.filter { app in
			let name = (app.value(forKey: "name") as? String ?? "").lowercased()
			return name.contains(lowercasedSearchText)
		} ?? []
	}
}

extension LibraryViewController: UISearchControllerDelegate, UISearchBarDelegate {
	func setupSearchController() {
		searchController = UISearchController(searchResultsController: nil)
		searchController.obscuresBackgroundDuringPresentation = false
		searchController.hidesNavigationBarDuringPresentation = true
		searchController.searchResultsUpdater = self
		searchController.delegate = self
		searchController.searchBar.placeholder = "Search Library"
		navigationItem.searchController = searchController
		definesPresentationContext = true
		navigationItem.hidesSearchBarWhenScrolling = false
	}
	
	var isFiltering: Bool {
		return searchController.isActive && !searchBarIsEmpty
	}

	var searchBarIsEmpty: Bool {
		return searchController.searchBar.text?.isEmpty ?? true
	}
}
