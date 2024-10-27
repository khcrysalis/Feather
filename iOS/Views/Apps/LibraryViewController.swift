//
//  LibraryViewController.swift
//  feather
//
//  Created by samara on 8/12/24.
//  Copyright (c) 2024 Samara M (khcrysalis)
//

import Foundation
import CoreData
import UniformTypeIdentifiers

class LibraryViewController: UITableViewController {
	var signedApps: [SignedApps]?
	var downloadedApps: [DownloadedApps]?
	
	var filteredSignedApps: [SignedApps] = []
	var filteredDownloadedApps: [DownloadedApps] = []
	
	var installer: Installer?
	
	public var searchController: UISearchController!
	var popupVC: PopupViewController!
	var loaderAlert: UIAlertController?
	
	init() { super.init(style: .grouped) }
	required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupViews()
		setupSearchController()
		fetchSources()
		loaderAlert = presentLoader()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		setupNavigation()
	}
	
	fileprivate func setupViews() {
		self.tableView.dataSource = self
		self.tableView.delegate = self
		tableView.register(AppsTableViewCell.self, forCellReuseIdentifier: "RoundedBackgroundCell")
		NotificationCenter.default.addObserver(self, selector: #selector(afetch), name: Notification.Name("lfetch"), object: nil)
		
	}
	
	deinit {
		NotificationCenter.default.removeObserver(self, name: Notification.Name("lfetch"), object: nil)
	}
	
	fileprivate func setupNavigation() {
		self.navigationController?.navigationBar.prefersLargeTitles = true
		self.title = String.localized("TAB_LIBRARY")
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
			let headerWithButton = GroupedSectionHeader(
                title: String.localized("LIBRARY_VIEW_CONTROLLER_SECTION_TITLE_SIGNED_APPS"),
				subtitle: String.localized(signedApps?.count ?? 0 > 1 ? "LIBRARY_VIEW_CONTROLLER_SECTION_TITLE_SIGNED_APPS_TOTAL_PLURAL" : "LIBRARY_VIEW_CONTROLLER_SECTION_TITLE_SIGNED_APPS_TOTAL", arguments: String(signedApps?.count ?? 0)),
                buttonTitle: String.localized("LIBRARY_VIEW_CONTROLLER_SECTION_BUTTON_IMPORT"),
                buttonAction: {
				self.startImporting()
			})
			return headerWithButton
		case 1:
            let headerWithButton = GroupedSectionHeader(title: String.localized("LIBRARY_VIEW_CONTROLLER_SECTION_DOWNLOADED_APPS"))
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
					self.popupVC.dismiss(animated: true)
					print(filePath?.path ?? "")
					self.startInstallProcess(meow: source!, filePath: filePath?.path ?? "")
				}
				
				let button4 = PopupViewControllerButton(title: "Open \((source!.value(forKey: "name") as? String ?? ""))", color: .quaternarySystemFill, titleColor: .tintColor)
				button4.onTap = { [weak self] in
					guard let self = self else { return }
					self.popupVC.dismiss(animated: true)
					if let workspace = LSApplicationWorkspace.default() {
						let success = workspace.openApplication(withBundleID: "\((source!.value(forKey: "bundleidentifier") as? String ?? ""))")
						if !success {
							Debug.shared.log(message: "Unable to open, do you have the app installed?", type: .warning)
						}
					}

				}
				
				let button3 = PopupViewControllerButton(title: "Resign \((source!.value(forKey: "name") as? String ?? ""))", color: .quaternarySystemFill, titleColor: .tintColor)
				button3.onTap = { [weak self] in
					guard let self = self else { return }
					self.popupVC.dismiss(animated: true) {
						self.present(self.loaderAlert!, animated: true)
						let cert = CoreDataManager.shared.getCurrentCertificate()!
						
						resignApp(certificate: cert, appPath: filePath2!) { success in
							if success {
								CoreDataManager.shared.updateSignedApp(app: source as! SignedApps, newTimeToLive: (cert.certData?.expirationDate)!, newTeamName: (cert.certData?.name)!) { _ in
									DispatchQueue.main.async {
										self.loaderAlert?.dismiss(animated: true)
										Debug.shared.log(message: "Done action??")
										self.tableView.reloadRows(at: [indexPath], with: .left)
									}
								}
							}
						}
					}
				}
				
				let button2 = PopupViewControllerButton(title: "Share \((source!.value(forKey: "name") as? String ?? ""))", color: .quaternarySystemFill, titleColor: .tintColor)
				button2.onTap = { [weak self] in
					guard let self = self else { return }
					self.popupVC.dismiss(animated: true)
					self.shareFile(meow: source!, filePath: filePath?.path ?? "")
				}
				popupVC.configureButtons([button1, button4, button3, button2])
				
				let detent2: UISheetPresentationController.Detent = ._detent(withIdentifier: "Test2", constant: 270.0)
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
				
				let singingData = SigningDataWrapper(signingOptions: UserDefaults.standard.signingOptions)
				let button1 = PopupViewControllerButton(
					title: singingData.signingOptions.installAfterSigned
					? "Sign & Install \((source!.value(forKey: "name") as? String ?? ""))"
					: "Sign \((source!.value(forKey: "name") as? String ?? ""))",
					color: .tintColor.withAlphaComponent(0.9))
				button1.onTap = { [weak self] in
					guard let self = self else { return }
					self.popupVC.dismiss(animated: true)
					self.startSigning(meow: source!)
				}
				
				let button2 = PopupViewControllerButton(title: "Install \((source!.value(forKey: "name") as? String ?? ""))", color: .quaternarySystemFill, titleColor: .tintColor)
				button2.onTap = { [weak self] in
					guard let self = self else { return }
					self.popupVC.dismiss(animated: true) {
						let alertController = UIAlertController(
							title: "Confirm Installation",
							message: "Trying to install via the downloaded apps tab may not work as they are most likely not signed! It's recommended you sign that application first before installing.",
							preferredStyle: .alert
						)
						
						let confirmAction = UIAlertAction(title: "Install", style: .default) { _ in
							self.startInstallProcess(meow: source!, filePath: filePath?.path ?? "")
							
						}
						
						let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
						
						alertController.addAction(confirmAction)
						alertController.addAction(cancelAction)
						
						self.present(alertController, animated: true, completion: nil)
					}
				}
				
				popupVC.configureButtons([button1, button2])
				
				let detent2: UISheetPresentationController.Detent = ._detent(withIdentifier: "Test2", constant: 150.0)
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
		if FileManager.default.fileExists(atPath: CoreDataManager.shared.getFilesForDownloadedApps(for:(meow as! DownloadedApps)).path) {
			let signingDataWrapper = SigningDataWrapper(signingOptions: UserDefaults.standard.signingOptions)
			let ap = SigningsViewController(signingDataWrapper: signingDataWrapper, application: meow, appsViewController: self)
			let navigationController = UINavigationController(rootViewController: ap)
			if UIDevice.current.userInterfaceIdiom == .pad {
				navigationController.modalPresentationStyle = .formSheet
			} else {
				navigationController.modalPresentationStyle = .fullScreen
			}
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
				self.present(navigationController, animated: true, completion: nil)
			}
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
        searchController.searchBar.placeholder = String.localized("SETTINGS_VIEW_CONTROLLER_SEARCH_PLACEHOLDER")
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

/// https://stackoverflow.com/a/75310581
func presentLoader() -> UIAlertController {
	let alert = UIAlertController(title: nil, message: "", preferredStyle: .alert)
	let activityIndicator = UIActivityIndicatorView(style: .large)
	activityIndicator.translatesAutoresizingMaskIntoConstraints = false
	activityIndicator.isUserInteractionEnabled = false
	activityIndicator.startAnimating()

	alert.view.addSubview(activityIndicator)
	
	NSLayoutConstraint.activate([
		alert.view.heightAnchor.constraint(equalToConstant: 95),
		alert.view.widthAnchor.constraint(equalToConstant: 95),
		activityIndicator.centerXAnchor.constraint(equalTo: alert.view.centerXAnchor),
		activityIndicator.centerYAnchor.constraint(equalTo: alert.view.centerYAnchor)
	])
	
	return alert
}

