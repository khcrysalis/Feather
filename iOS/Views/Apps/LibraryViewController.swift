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
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(handleInstallNotification(_:)),
			name: Notification.Name("InstallDownloadedApp"),
			object: nil
		)
	}
	
	@objc private func handleInstallNotification(_ notification: Notification) {
		guard let downloadedApp = notification.userInfo?["downloadedApp"] as? DownloadedApps else { return }
		
		let signingDataWrapper = SigningDataWrapper(signingOptions: UserDefaults.standard.signingOptions)
		signingDataWrapper.signingOptions.installAfterSigned = true
		
		let ap = SigningsViewController(
			signingDataWrapper: signingDataWrapper,
			application: downloadedApp,
			appsViewController: self
		)
		
		ap.signingCompletionHandler = { success in
			if success {
				Debug.shared.log(message: "Signing completed successfully", type: .success)
			}
		}
		
		let navigationController = UINavigationController(rootViewController: ap)
		navigationController.shouldPresentFullScreen()
		
		present(navigationController, animated: true)
	}
	
	deinit {
		NotificationCenter.default.removeObserver(self, name: Notification.Name("lfetch"), object: nil)
		NotificationCenter.default.removeObserver(self, name: Notification.Name("InstallDownloadedApp"), object: nil)
	}
	
	fileprivate func setupNavigation() {
		self.navigationController?.navigationBar.prefersLargeTitles = true
		self.title = String.localized("TAB_LIBRARY")
	}
	
	private func handleAppUpdate(for signedApp: SignedApps) {
        guard let sourceURL = signedApp.originalSourceURL else {
			Debug.shared.log(message: "Missing update version or source URL", type: .error)
			return
		}
		
		Debug.shared.log(message: "Fetching update from source: \(sourceURL.absoluteString)", type: .info)
		
		present(loaderAlert!, animated: true)
		
		// Create mock source if in debug mode
		if isDebugMode {
			let mockSource = SourceRefreshOperation()
			mockSource.createMockSource { mockSourceData in
				if let sourceData = mockSourceData {
					self.handleSourceData(sourceData, for: signedApp)
				} else {
					Debug.shared.log(message: "Failed to create mock source", type: .error)
					DispatchQueue.main.async {
						self.loaderAlert?.dismiss(animated: true)
					}
				}
			}
		} else {
			// Normal source fetch
			SourceGET().downloadURL(from: sourceURL) { [weak self] result in
				guard let self = self else { return }
				
				switch result {
				case .success((let data, _)):
					if case .success(let sourceData) = SourceGET().parse(data: data) {
						self.handleSourceData(sourceData, for: signedApp)
					} else {
						Debug.shared.log(message: "Failed to parse source data", type: .error)
						DispatchQueue.main.async {
							self.loaderAlert?.dismiss(animated: true)
						}
					}
				case .failure(let error):
					Debug.shared.log(message: "Failed to fetch source: \(error)", type: .error)
					DispatchQueue.main.async {
						self.loaderAlert?.dismiss(animated: true)
					}
				}
			}
		}
	}
	
	private func handleSourceData(_ sourceData: SourcesData, for signedApp: SignedApps) {
		guard let bundleId = signedApp.bundleidentifier,
			  let updateVersion = signedApp.updateVersion,
			  let app = sourceData.apps.first(where: { $0.bundleIdentifier == bundleId }),
			  let versions = app.versions else {
			Debug.shared.log(message: "Failed to find app in source", type: .error)
			DispatchQueue.main.async {
				self.loaderAlert?.dismiss(animated: true)
			}
			return
		}
		
		// Look for the version that matches our update version
		for version in versions {
			if version.version == updateVersion {
				// Found the matching version
				Debug.shared.log(message: "Found matching version: \(version.version)", type: .info)
				
				let uuid = UUID().uuidString
				
				DispatchQueue.global(qos: .background).async {
					do {
						let tempDirectory = FileManager.default.temporaryDirectory
						let destinationURL = tempDirectory.appendingPathComponent("\(uuid).ipa")
						
						// Download the file
						if let data = try? Data(contentsOf: version.downloadURL) {
							try data.write(to: destinationURL)
							
							let dl = AppDownload()
							try handleIPAFile(destinationURL: destinationURL, uuid: uuid, dl: dl)
							
							DispatchQueue.main.async {
								self.loaderAlert?.dismiss(animated: true) {
									// Force Sign & Install
									let downloadedApps = CoreDataManager.shared.getDatedDownloadedApps()
									if let downloadedApp = downloadedApps.first(where: { $0.uuid == uuid }) {
										let signingDataWrapper = SigningDataWrapper(signingOptions: UserDefaults.standard.signingOptions)
										signingDataWrapper.signingOptions.installAfterSigned = true
										
										// Store the original signed app for deletion after update
										let originalSignedApp = signedApp
										
										let ap = SigningsViewController(
											signingDataWrapper: signingDataWrapper,
											application: downloadedApp,
											appsViewController: self
										)
										
										// Add completion handler to delete the original app after successful signing
										ap.signingCompletionHandler = { [weak self] success in
											if success {
												CoreDataManager.shared.deleteAllSignedAppContent(for: originalSignedApp)
												self?.fetchSources()
												self?.tableView.reloadData()
											}
										}
										
										let navigationController = UINavigationController(rootViewController: ap)
										
										navigationController.shouldPresentFullScreen()
										
										self.present(navigationController, animated: true)
									}
								}
							}
						}
					} catch {
						Debug.shared.log(message: "Failed to handle update: \(error)", type: .error)
						DispatchQueue.main.async {
							self.loaderAlert?.dismiss(animated: true)
						}
					}
				}
				return
			}
		}
		
		Debug.shared.log(message: "Could not find version \(updateVersion) in source", type: .error)
		DispatchQueue.main.async {
			self.loaderAlert?.dismiss(animated: true)
		}
	}
	
	private var isDebugMode: Bool {
		var isDebug = false
		assert({
			isDebug = true
			return true
		}())
		return isDebug
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
				subtitle: String.localized("LIBRARY_VIEW_CONTROLLER_SECTION_TITLE_SIGNED_APPS_TOTAL", arguments: String(signedApps?.count ?? 0)),
                buttonTitle: String.localized("LIBRARY_VIEW_CONTROLLER_SECTION_BUTTON_IMPORT"),
                buttonAction: {
				self.startImporting()
			})
			return headerWithButton
		case 1:
			
			let headerWithButton = GroupedSectionHeader(
				title: String.localized("LIBRARY_VIEW_CONTROLLER_SECTION_DOWNLOADED_APPS"),
				subtitle: String.localized("LIBRARY_VIEW_CONTROLLER_SECTION_TITLE_DOWNLOADED_APPS_TOTAL", arguments: String(downloadedApps?.count ?? 0))
			)
			
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
		let appName = "\((source!.value(forKey: "name") as? String ?? ""))"
		switch indexPath.section {
		case 0:
			if FileManager.default.fileExists(atPath: filePath2!.path) {
				popupVC = PopupViewController()
				popupVC.modalPresentationStyle = .pageSheet
				
				let hasUpdate = (source as? SignedApps)?.value(forKey: "hasUpdate") as? Bool ?? false
				
				if let signedApp = source as? SignedApps,
				   hasUpdate {
					// Update available menu
					let updateButton = PopupViewControllerButton(
						title: String.localized("LIBRARY_VIEW_CONTROLLER_SIGN_ACTION_UPDATE", arguments: appName),
						color: .tintColor.withAlphaComponent(0.9),
						titleColor: .white
					)
					updateButton.onTap = { [weak self] in
						guard let self = self else { return }
						self.popupVC.dismiss(animated: true) {
							self.handleAppUpdate(for: signedApp)
						}
					}
					
					let clearButton = PopupViewControllerButton(
						title: String.localized("LIBRARY_VIEW_CONTROLLER_SIGN_ACTION_CLEAR_UPDATE"),
						color: .quaternarySystemFill,
						titleColor: .tintColor
					)
					clearButton.onTap = { [weak self] in
						guard let self = self else { return }
						self.popupVC.dismiss(animated: true)
						CoreDataManager.shared.clearUpdateState(for: signedApp)
						self.tableView.reloadRows(at: [indexPath], with: .none)
					}
					
					popupVC.configureButtons([updateButton, clearButton])
				} else {
					// Regular menu
					let button1 = PopupViewControllerButton(
						title: String.localized("LIBRARY_VIEW_CONTROLLER_SIGN_ACTION_INSTALL", arguments: appName),
						color: .tintColor.withAlphaComponent(0.9)
					)
					button1.onTap = { [weak self] in
						guard let self = self else { return }
						self.popupVC.dismiss(animated: true)
						self.startInstallProcess(meow: source!, filePath: filePath?.path ?? "")
					}
					
					let button4 = PopupViewControllerButton(
						title: String.localized("LIBRARY_VIEW_CONTROLLER_SIGN_ACTION_OPEN", arguments: appName),
						color: .quaternarySystemFill,
						titleColor: .tintColor
					)
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
					
					let button3 = PopupViewControllerButton(
						title: String.localized("LIBRARY_VIEW_CONTROLLER_SIGN_ACTION_RESIGN", arguments: appName),
						color: .quaternarySystemFill,
						titleColor: .tintColor
					)
					button3.onTap = { [weak self] in
						guard let self = self else { return }
						self.popupVC.dismiss(animated: true) {
							if let cert = CoreDataManager.shared.getCurrentCertificate() {
								self.present(self.loaderAlert!, animated: true)
								
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
							} else {
								let alert = UIAlertController(
									title: String.localized("APP_SIGNING_VIEW_CONTROLLER_NO_CERTS_ALERT_TITLE"),
									message: String.localized("APP_SIGNING_VIEW_CONTROLLER_NO_CERTS_ALERT_DESCRIPTION"),
									preferredStyle: .alert
								)
								alert.addAction(UIAlertAction(title: String.localized("LAME"), style: .default))
								self.present(alert, animated: true)
							}
						}
					}
					
					let button2 = PopupViewControllerButton(
						title: String.localized("LIBRARY_VIEW_CONTROLLER_SIGN_ACTION_SHARE", arguments: appName),
						color: .quaternarySystemFill,
						titleColor: .tintColor
					)
					button2.onTap = { [weak self] in
						guard let self = self else { return }
						self.popupVC.dismiss(animated: true)
						self.shareFile(meow: source!, filePath: filePath?.path ?? "")
					}
					
					popupVC.configureButtons([button1, button4, button3, button2])
				}
				let detent2: UISheetPresentationController.Detent = ._detent(withIdentifier: "Test2", constant: hasUpdate ? 150.0 : 270.0)
				if let presentationController = popupVC.presentationController as? UISheetPresentationController {
					presentationController.detents = [
						detent2,
						.medium()
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
                    ? String.localized("LIBRARY_VIEW_CONTROLLER_SIGN_ACTION_SIGN_INSTALL", arguments: appName)
                    : String.localized("LIBRARY_VIEW_CONTROLLER_SIGN_ACTION_SIGN", arguments: appName),
					color: .tintColor.withAlphaComponent(0.9))
				button1.onTap = { [weak self] in
					guard let self = self else { return }
					self.popupVC.dismiss(animated: true)
					self.startSigning(meow: source!)
				}
				
				let button2 = PopupViewControllerButton(title: String.localized("LIBRARY_VIEW_CONTROLLER_SIGN_ACTION_INSTALL", arguments: appName), color: .quaternarySystemFill, titleColor: .tintColor)
				button2.onTap = { [weak self] in
					guard let self = self else { return }
					self.popupVC.dismiss(animated: true) {
						let alertController = UIAlertController(
                            title: String.localized("LIBRARY_VIEW_CONTROLLER_SIGN_ACTION_INSTALL_CONFIRM"),
                            message: String.localized("LIBRARY_VIEW_CONTROLLER_SIGN_ACTION_INSTALL_CONFIRM_DESCRIPTION"),
							preferredStyle: .alert
						)
						
                        let confirmAction = UIAlertAction(title: String.localized("INSTALL"), style: .default) { _ in
							self.startInstallProcess(meow: source!, filePath: filePath?.path ?? "")
							
						}
						
                        let cancelAction = UIAlertAction(title: String.localized("CANCEL"), style: .cancel, handler: nil)
						
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
			navigationController.shouldPresentFullScreen()
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
				self.present(navigationController, animated: true, completion: nil)
			}
		}
	}
	
	override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		let source = getApplication(row: indexPath.row, section: indexPath.section)
		
		let deleteAction = UIContextualAction(style: .destructive, title: String.localized("DELETE")) { (action, view, completionHandler) in
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
				UIAction(title: String.localized("LIBRARY_VIEW_CONTROLLER_SIGN_ACTION_VIEW_DATEILS"), image: UIImage(systemName: "info.circle"), handler: {_ in
										
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
				
				UIAction(title: String.localized("LIBRARY_VIEW_CONTROLLER_SIGN_ACTION_OPEN_LN_FILES"), image: UIImage(systemName: "folder"), handler: {_ in
					
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

