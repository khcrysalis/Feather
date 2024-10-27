//
//  SigningsViewController.swift
//  feather
//
//  Created by samara on 26.10.2024.
//

import UIKit
import CoreData

struct BundleOptions {
	var name: String?
	var bundleId: String?
	var version: String?
}

class SigningsViewController: UIViewController {
	
	var tableData = [
		[
			"AppIcon",
			String.localized("APPS_INFORMATION_TITLE_NAME"),
			String.localized("APPS_INFORMATION_TITLE_IDENTIFIER"),
			String.localized("APPS_INFORMATION_TITLE_VERSION"),
		],
		[ 
			"Signing",
//			"Change Certificate",
		],
		[
			"Add Tweaks",
			"Modify Dylibs",
		],
		[ "Properties" ],
	]

	var sectionTitles = [
		String.localized("APP_SIGNING_VIEW_CONTROLLER_CELL_TITLE_CUSTOMIZATION"),
		String.localized("APP_SIGNING_VIEW_CONTROLLER_CELL_TITLE_SIGNING"),
		String.localized("APP_SIGNING_VIEW_CONTROLLER_CELL_TITLE_ADVANCED"),
		"",
	]
	
	private var application: NSManagedObject?
	private var appsViewController: LibraryViewController?
		
	var signingDataWrapper: SigningDataWrapper
	var mainOptions = SigningMainDataWrapper(mainOptions: MainSigningOptions())
	
	var bundle: BundleOptions?
	
	var tableView: UITableView!
	private var variableBlurView: UIVariableBlurView?
	private var largeButton = ActivityIndicatorButton()
	private var iconCell = IconImageViewCell()
	
	init(signingDataWrapper: SigningDataWrapper, application: NSManagedObject, appsViewController: LibraryViewController) {
		self.signingDataWrapper = signingDataWrapper
		self.application = application
		self.appsViewController = appsViewController
		super.init(nibName: nil, bundle: nil)
		
		if let name = application.value(forKey: "name") as? String,
			let bundleId = application.value(forKey: "bundleidentifier") as? String,
			let version = application.value(forKey: "version") as? String {
			self.bundle = BundleOptions(name: name, bundleId: bundleId, version: version)
		}
		
		if let hasGotCert = CoreDataManager.shared.getCurrentCertificate() { self.mainOptions.mainOptions.certificate = hasGotCert }
		if let uuid = application.value(forKey: "uuid") as? String { self.mainOptions.mainOptions.uuid = uuid }
		
		if signingDataWrapper.signingOptions.ppqCheckProtection &&
			mainOptions.mainOptions.certificate?.certData?.pPQCheck == true {
			mainOptions.mainOptions.bundleId = (bundle?.bundleId)!+"."+Preferences.pPQCheckString
		}
		
		if let currentBundleId = bundle?.bundleId,
		   let newBundleId = signingDataWrapper.signingOptions.bundleIdConfig[currentBundleId] {
			mainOptions.mainOptions.bundleId = newBundleId
		}
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupNavigation()
		setupViews()
		setupToolbar()
		#if !targetEnvironment(simulator)
		certAlert()
		#endif
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.tableView.reloadData()
	}
	
	fileprivate func setupNavigation() {
		let logoImageView = UIImageView(image: UIImage(named: "feather_glyph"))
		logoImageView.contentMode = .scaleAspectFit
		navigationItem.titleView = logoImageView
		self.navigationController?.navigationBar.prefersLargeTitles = false
		
		self.isModalInPresentation = true
		self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: String.localized("DISMISS"), style: .done, target: self, action: #selector(closeSheet))
	}
	
	fileprivate func setupViews() {
		self.tableView = UITableView(frame: .zero, style: .insetGrouped)
		self.tableView.translatesAutoresizingMaskIntoConstraints = false
		self.tableView.dataSource = self
		self.tableView.delegate = self
		self.tableView.showsHorizontalScrollIndicator = false
		self.tableView.showsVerticalScrollIndicator = false
		self.tableView.contentInset.bottom = 70
				
		self.view.addSubview(tableView)
		self.tableView.constraintCompletely(to: view)
	}
	
	fileprivate func setupToolbar() {
		largeButton.translatesAutoresizingMaskIntoConstraints = false
		largeButton.addTarget(self, action: #selector(startSign), for: .touchUpInside)
		
		let gradientMask = VariableBlurViewConstants.defaultGradientMask
		variableBlurView = UIVariableBlurView(frame: .zero)
		variableBlurView?.gradientMask = gradientMask
		variableBlurView?.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
		variableBlurView?.translatesAutoresizingMaskIntoConstraints = false
		
		view.addSubview(variableBlurView!)
		view.addSubview(largeButton)
		
		var height = 80.0
		if UIDevice.current.userInterfaceIdiom == .pad { height = 65.0 }
		
		NSLayoutConstraint.activate([
			variableBlurView!.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
			variableBlurView!.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
			variableBlurView!.bottomAnchor.constraint(equalTo: view.bottomAnchor),
			variableBlurView!.heightAnchor.constraint(equalToConstant: height),
			
			largeButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
			largeButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
			largeButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -17),
			largeButton.heightAnchor.constraint(equalToConstant: 50)
		])
		
		variableBlurView?.layer.zPosition = 3
		largeButton.layer.zPosition = 4
	}
	
	fileprivate func certAlert() {
		if (mainOptions.mainOptions.certificate == nil) {
			DispatchQueue.main.async {
				let alert = UIAlertController(
					title: String.localized("APP_SIGNING_VIEW_CONTROLLER_NO_CERTS_ALERT_TITLE"),
					message: String.localized("APP_SIGNING_VIEW_CONTROLLER_NO_CERTS_ALERT_DESCRIPTION"),
					preferredStyle: .alert
				)
				alert.addAction(UIAlertAction(title: String.localized("LAME"), style: .default) { _ in
						self.dismiss(animated: true)
					}
				)
				self.present(alert, animated: true, completion: nil)
			}
		}
	}
	
	@objc func closeSheet() {
		dismiss(animated: true, completion: nil)
	}
	
	@objc func startSign() {
		self.navigationItem.leftBarButtonItem = nil
		largeButton.showLoadingIndicator()
		signInitialApp(
			bundle: bundle!,
			mainOptions: mainOptions,
			signingOptions: signingDataWrapper,
			appPath:getFilesForDownloadedApps(app: application as! DownloadedApps, getuuidonly: false))
		{ result in
			switch result {
			case .success(let (signedPath, signedApp)):
				self.appsViewController?.fetchSources()
				self.appsViewController?.tableView.reloadData()
				Debug.shared.log(message: signedPath.path)
				if self.signingDataWrapper.signingOptions.installAfterSigned {
					self.appsViewController?.startInstallProcess(meow: signedApp, filePath: signedPath.path)
				}

			case .failure(let error):
				Debug.shared.log(message: "Signing failed: \(error.localizedDescription)", type: .error)
			}
			
			self.dismiss(animated: true)
		}
	}
}

extension SigningsViewController: UITableViewDataSource, UITableViewDelegate  {
	func numberOfSections(in tableView: UITableView) -> Int { return sectionTitles.count }
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return tableData[section].count }
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? { return sectionTitles[section] }
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat { return sectionTitles[section].isEmpty ? 0 : 40 }
	
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let title = sectionTitles[section]
		let headerView = InsetGroupedSectionHeader(title: title)
		return headerView
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let reuseIdentifier = "Cell"
		let cell = UITableViewCell(style: .value1, reuseIdentifier: reuseIdentifier)
		cell.accessoryType = .none
		cell.selectionStyle = .gray
		
		let cellText = tableData[indexPath.section][indexPath.row]
		cell.textLabel?.text = cellText
		
		switch cellText {
		case "AppIcon":
			let cell = iconCell
			
			if (mainOptions.mainOptions.iconURL != nil) {
				cell.configure(with: mainOptions.mainOptions.iconURL)
			} else {
				cell.configure(with: CoreDataManager.shared.loadImage(from: getIconURL(for: application as! DownloadedApps)))
			}
			
			cell.accessoryType = .disclosureIndicator
			return cell
		case String.localized("APPS_INFORMATION_TITLE_NAME"):
			cell.textLabel?.text = String.localized("APPS_INFORMATION_TITLE_NAME")
			cell.detailTextLabel?.text = mainOptions.mainOptions.name ?? bundle?.name
			cell.accessoryType = .disclosureIndicator
		case String.localized("APPS_INFORMATION_TITLE_IDENTIFIER"):
			cell.textLabel?.text = String.localized("APPS_INFORMATION_TITLE_IDENTIFIER")
			cell.detailTextLabel?.text = mainOptions.mainOptions.bundleId ?? bundle?.bundleId
			cell.accessoryType = .disclosureIndicator
		case String.localized("APPS_INFORMATION_TITLE_VERSION"):
			cell.detailTextLabel?.text = mainOptions.mainOptions.version ?? bundle?.version
			cell.accessoryType = .disclosureIndicator
		case "Signing":
			if let hasGotCert = mainOptions.mainOptions.certificate {
				let cell = CertificateViewTableViewCell()
				cell.configure(with: hasGotCert, isSelected: false)
				cell.selectionStyle = .none
				return cell
			} else {
				cell.textLabel?.text = String.localized("SETTINGS_VIEW_CONTROLLER_CELL_CURRENT_CERTIFICATE_NOSELECTED")
				cell.textLabel?.textColor = .secondaryLabel
				cell.selectionStyle = .none
			}
		case "Change Certificate", "Add Tweaks", "Modify Dylibs", "Properties":
			cell.accessoryType = .disclosureIndicator
		default:
			break
		}

		
		return cell
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let itemTapped = tableData[indexPath.section][indexPath.row]
		switch itemTapped {
		case "AppIcon":
			importAppIconFile()
		case String.localized("APPS_INFORMATION_TITLE_NAME"):
			let l = SigningsInputViewController(v: self, initialValue: (mainOptions.mainOptions.name ?? bundle?.name)!, valueToSaveTo: indexPath.row)
			navigationController?.pushViewController(l, animated: true)
		case String.localized("APPS_INFORMATION_TITLE_IDENTIFIER"):
			let l = SigningsInputViewController(v: self, initialValue: (mainOptions.mainOptions.bundleId ?? bundle?.bundleId)!, valueToSaveTo: indexPath.row)
			navigationController?.pushViewController(l, animated: true)
		case String.localized("APPS_INFORMATION_TITLE_VERSION"):
			let l = SigningsInputViewController(v: self, initialValue: (mainOptions.mainOptions.version ?? bundle?.version)!, valueToSaveTo: indexPath.row)
			navigationController?.pushViewController(l, animated: true)
		case "Add Tweaks":
			let l = SigningsTweakViewController(signingDataWrapper: signingDataWrapper)
			navigationController?.pushViewController(l, animated: true)
		case "Modify Dylibs":
			let l = SigningsDylibViewController(mainOptions: mainOptions, app: getFilesForDownloadedApps(app: application as! DownloadedApps, getuuidonly: false))
			navigationController?.pushViewController(l, animated: true)
		case "Properties":
			let l = SigningsAdvancedViewController(signingDataWrapper: signingDataWrapper, mainOptions: mainOptions)
			navigationController?.pushViewController(l, animated: true)
		default:
			break
		}
		
		tableView.deselectRow(at: indexPath, animated: true)
	}
}

// MARK: - this sucks

extension SigningsViewController {
	
	private func getFilesForDownloadedApps(app: DownloadedApps, getuuidonly: Bool) -> URL {
		return CoreDataManager.shared.getFilesForDownloadedApps(for: app, getuuidonly: getuuidonly)
	}
	
	private func getIconURL(for app: DownloadedApps) -> URL? {
		guard let iconURLString = app.value(forKey: "iconURL") as? String,
			  let iconURL = URL(string: iconURLString) else {
			return nil
		}
		
		let filesURL = getFilesForDownloadedApps(app: app, getuuidonly: false)
		return filesURL.appendingPathComponent(iconURL.lastPathComponent)
	}
}
