//
//  AppsViewController.swift
//  feather
//
//  Created by samara on 5/19/24.
//

import UIKit
import CoreData
import MBProgressHUD

class SignedAppsViewController: UITableViewController {
    var apps: [SignedApps]?
    
    init() { super.init(style: .plain) }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
        setupViews()
        fetchSources()
    }
    
    fileprivate func setupViews() {
        self.tableView.dataSource = self
        self.tableView.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(afetch), name: Notification.Name("afetch"), object: nil)
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: Notification.Name("afetch"), object: nil)
    }
    
    fileprivate func setupNavigation() {
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        var rightBarButtonItems: [UIBarButtonItem] = []
        
        let libraryButton = UIBarButtonItem(title: "Library", style: .plain, target: self, action: #selector(showLibrary))
        rightBarButtonItems.append(libraryButton)
        
        
        navigationItem.rightBarButtonItems = rightBarButtonItems
    }
    
    @objc func showLibrary() {
        let viewController = DownloadedAppsViewController()
        let navigationController = UINavigationController(rootViewController: viewController)
        self.present(navigationController, animated: true)
    }
}

extension SignedAppsViewController {
    override func numberOfSections(in tableView: UITableView) -> Int { return 1 }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return apps?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = AppsTableViewCell(style: .subtitle, reuseIdentifier: "RoundedBackgroundCell")
        cell.selectionStyle = .default
        cell.accessoryType = .disclosureIndicator
        
        let source = getApplication(row: indexPath.row)
        let filePath = getApplicationFilePath(with: source!, row: indexPath.row)
        
        
        if let iconURL = source!.value(forKey: "iconURL") as? String {
            let imagePath = filePath.appendingPathComponent(iconURL)
            
            if let image = CoreDataManager.shared.loadImage(from: imagePath) {
                SectionIcons.sectionImage(to: cell, with: image)
            } else {
                SectionIcons.sectionImage(to: cell, with: UIImage(named: "unknown")!)
            }
        } else {
            SectionIcons.sectionImage(to: cell, with: UIImage(named: "unknown")!)
        }
        
        cell.configure(with: source!, filePath: filePath)
        return cell
    }
    
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		guard let meow = getApplication(row: indexPath.row) else { return }
		
		let filePath = getApplicationFilePath(with: meow, row: indexPath.row, getuuidonly: true).path
		let uuid = UUID().uuidString
		let tempDirectory = NSHomeDirectory() + "/tmp/\(uuid)"
		let payloadPath = "\(tempDirectory)/Payload"
		let ipaPath = "\(tempDirectory).ipa"
		
		do {
			UIApplication.shared.isIdleTimerDisabled = true
			try FileManager.default.createDirectory(atPath: tempDirectory, withIntermediateDirectories: true)
			try FileManager.default.copyItem(atPath: filePath, toPath: payloadPath)
			MBProgressHUD.showAdded(to: self.view, animated: true)
			DispatchQueue(label: "compress").async {
				do {
					let payloadURL = URL(fileURLWithPath: payloadPath)
					let ipaURL = URL(fileURLWithPath: ipaPath)
					try FileManager.default.zipItem(at: payloadURL, to: ipaURL)
					UIApplication.shared.isIdleTimerDisabled = false
					DispatchQueue.main.async {
						tableView.deselectRow(at: indexPath, animated: true)
						MBProgressHUD.hide(for: self.view, animated: true)
						runHTTPSServer()
						UIApplication.shared.open(URL(string: "itms-services://?action=download-manifest&url=\("https://localhost.direct:8443/manifest.plist?bundleid=\(meow.value(forKey: "bundleidentifier") as? String ?? "")&uuid=\(uuid)&name=\((meow.value(forKey: "name") as? String ?? "").addingPercentEncoding(withAllowedCharacters: .alphanumerics)!)".addingPercentEncoding(withAllowedCharacters: .alphanumerics)!)")!, options: [:], completionHandler: nil)

					}
				} catch {
					DispatchQueue.main.async {
						MBProgressHUD.hide(for: self.view, animated: true)
					}
					Debug.shared.log(message: "\(error)", type: .error)
				}
			}
		} catch {
			Debug.shared.log(message: "\(error)", type: .error)
		}
	}

    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let source = getApplication(row: indexPath.row)
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completionHandler) in
            CoreDataManager.shared.deleteAllSignedAppContent(for: source! as! SignedApps)
            self.apps?.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            completionHandler(true)
        }
        
        deleteAction.backgroundColor = UIColor.red
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = true
        
        return configuration
    }
    
    override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let source = getApplication(row: indexPath.row)
        let filePath = getApplicationFilePath(with: source!, row: indexPath.row)
        
        let configuration = UIContextMenuConfiguration(identifier: nil, actionProvider: { _ in
            return UIMenu(title: "", image: nil, identifier: nil, options: [], children: [
                UIAction(title: "View Details", image: UIImage(systemName: "info.circle"), handler: {_ in
                    
                    
                    //					self.showAlertWithImageAndBoldText(with: source!, filePath: filePath)
                    
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
                    
                    let path = filePath.deletingLastPathComponent()
                    let path2 = path.absoluteString.replacingOccurrences(of: "file://", with: "shareddocuments://")
                    
                    UIApplication.shared.open(URL(string: path2)!, options: [:]) { success in
                        if success {
                            print("File opened successfully.")
                        } else {
                            print("Failed to open file.")
                        }
                    }
                })
                
            ])
        })
        return configuration
    }
}

extension SignedAppsViewController {
    @objc func afetch() { self.fetchSources() }
    func fetchSources() {
        apps = CoreDataManager.shared.getDatedSignedApps()
        DispatchQueue.main.async { self.tableView.reloadData() }
    }
    
    func getApplicationFilePath(with app: NSManagedObject, row: Int, getuuidonly: Bool = false) -> URL {
        guard let source = getApplication(row: row) as? SignedApps else {
            return URL(string: "")!
        }
        return CoreDataManager.shared.getFilesForSignedApps(for: source, getuuidonly: getuuidonly)
    }
    
    func getApplication(row: Int) -> NSManagedObject? {
        return apps?[row]
    }
}
