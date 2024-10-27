//
//  AppSigningDylibViewController.swift
//  feather
//
//  Created by samara on 29.08.2024.
//

import UIKit

class SigningsDylibViewController: UITableViewController {
	var applicationPath: URL
	var groupedDylibs: [String: [String]] = [:]
	var dylibSections: [String] = ["@rpath", "@executable_path", "/usr/lib", "/System/Library", "Other"]
	var dylibstoremove: [String] = [] {
		didSet {
			self.mainOptions.mainOptions.removeInjectPaths = self.dylibstoremove
		}
	}
	
	var mainOptions: SigningMainDataWrapper

	init(mainOptions: SigningMainDataWrapper, app: URL) {
		self.mainOptions = mainOptions
		self.applicationPath = app
		super.init(style: .insetGrouped)

		do {
			let balls = try TweakHandler.findExecutable(at: applicationPath)
			if let dylibs = listDylibs(filePath: balls!.path) {
				groupDylibs(dylibs)
			}
		} catch {
			print(error)
		}
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		setupViews()
		setupNavigation()
		self.dylibstoremove = self.mainOptions.mainOptions.removeInjectPaths
		
	}

	fileprivate func setupViews() {
		self.tableView.dataSource = self
		self.tableView.delegate = self
		tableView.register(UITableViewCell.self, forCellReuseIdentifier: "dylibCell")
		
		let alertController = UIAlertController(title: "ADVANCED USERS ONLY", message: "This section can make installed applications UNUSABLE and potentially UNSTABLE. USE THIS SECTION WITH CAUTION, IF YOU HAVE NO IDEA WHAT YOU'RE DOING, PLEASE LEAVE.\n\nIF YOU MAKE AN ISSUE ON THIS, IT WILL IMMEDIATELY BE CLOSED AND IGNORED.", preferredStyle: .alert)
		
		let continueAction = UIAlertAction(title: "WHO CARES", style: .destructive, handler: nil)
		
		alertController.addAction(continueAction)
		
		present(alertController, animated: true, completion: nil)
		
	}

	fileprivate func setupNavigation() {
		title = "Remove Dylibs"
		
	}

	fileprivate func groupDylibs(_ dylibs: [String]) {
		groupedDylibs["@rpath"] = dylibs.filter { $0.hasPrefix("@rpath") }
		groupedDylibs["@executable_path"] = dylibs.filter { $0.hasPrefix("@executable_path") }
		groupedDylibs["/usr/lib"] = dylibs.filter { $0.hasPrefix("/usr/lib") }
		groupedDylibs["/System/Library"] = dylibs.filter { $0.hasPrefix("/System/Library") }
		groupedDylibs["Other"] = dylibs.filter { dylib in
			!dylib.hasPrefix("@rpath") &&
			!dylib.hasPrefix("@executable_path") &&
			!dylib.hasPrefix("/usr/lib") &&
			!dylib.hasPrefix("/System/Library")
		}
	}

	override func numberOfSections(in tableView: UITableView) -> Int {
		return dylibSections.count
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		let key = dylibSections[section]
		return groupedDylibs[key]?.count ?? 0
	}

	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return dylibSections[section]
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "dylibCell", for: indexPath)
		let key = dylibSections[indexPath.section]
		if let dylib = groupedDylibs[key]?[indexPath.row] {
			cell.textLabel?.text = dylib
			cell.textLabel?.textColor = dylibstoremove.contains(dylib) ? .systemRed : .label
		}
		return cell
	}

	override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
		if editingStyle == .delete {
			let key = dylibSections[indexPath.section]
			if let dylib = groupedDylibs[key]?[indexPath.row] {
				if !dylibstoremove.contains(dylib) {
					dylibstoremove.append(dylib)
				}
				tableView.reloadRows(at: [indexPath], with: .automatic)
				print(dylibstoremove)
			}
		}
	}

}
