//
//  AppsInfoAlert.swift
//  feather
//
//  Created by samara on 7/1/24.
//

import Foundation
import UIKit
import CoreData

extension AppsViewController {
	func showAlertWithImageAndBoldText(with app: NSManagedObject, filePath: URL) {
		let alert = UIAlertController(title: "\n\n\n\n\n\n\n\n\n\n\n\n", message: nil, preferredStyle: .alert)
		
		var balls: UIImage
		var appname = ""
		var appversion = ""
		var appdateadded = Date()
		var appbundleid = ""
		var apppath = ""
		var iconurl = ""
		var apppathC: UIColor
		var lastLabel: UILabel?
		
		if let iconURL = app.value(forKey: "iconURL") as? String {
			iconurl = iconURL
			let imagePath = filePath.appendingPathComponent(iconURL)
			if let image = self.loadImage(from: imagePath) {
				balls = image
			} else {
				balls = UIImage(named: "unknown")!
			}
		} else {
			balls = UIImage(named: "unknown")!
		}
		
		if let name = app.value(forKey: "name") as? String { appname += name }
		if let version = app.value(forKey: "version") as? String { appversion = version }
		if let date = app.value(forKey: "dateAdded") as? Date { appdateadded = date }
		
		if let bundleIdentifier = app.value(forKey: "bundleidentifier") as? String {
			appbundleid = bundleIdentifier
			if bundleIdentifier.hasSuffix("Beta") { appname += " (Beta)" }
		}
		
		
		if let a = app.value(forKey: "appPath") as? String { apppath = a }
		if FileManager.default.fileExists(atPath: filePath.path) {
			apppathC = .label
		} else {
			apppathC = .systemRed
		}
		
		
		let imageView = UIImageView()
		imageView.contentMode = .scaleAspectFit
		imageView.image = balls
		imageView.layer.cornerRadius = 6
		imageView.clipsToBounds = true
		imageView.layer.cornerCurve = .continuous
		imageView.layer.borderWidth = 1
		imageView.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.3).cgColor
		alert.view.addSubview(imageView)
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.leadingAnchor.constraint(equalTo: alert.view.leadingAnchor, constant: 12).isActive = true
		imageView.topAnchor.constraint(equalTo: alert.view.topAnchor, constant: 12).isActive = true
		imageView.widthAnchor.constraint(equalToConstant: 30).isActive = true
		imageView.heightAnchor.constraint(equalToConstant: 30).isActive = true
		
		let titleLabel = UILabel()
		titleLabel.text = appname
		titleLabel.textAlignment = .left
		titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
		titleLabel.numberOfLines = 0
		alert.view.addSubview(titleLabel)
		titleLabel.translatesAutoresizingMaskIntoConstraints = false
		titleLabel.topAnchor.constraint(equalTo: alert.view.topAnchor, constant: 16).isActive = true
		titleLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 12).isActive = true
		
		let versionTitle = addLabelToAlert(text: "Version", bold: true, toView: alert.view, below: titleLabel, constant: 14)
		lastLabel = addLabelToAlert(text: appversion, toView: alert.view, below: versionTitle, constant: 5)

		let bundleidTitle = addLabelToAlert(text: "Bundle Identifier", bold: true, toView: alert.view, below: lastLabel, constant: 12)
		lastLabel = addLabelToAlert(text: appbundleid, toView: alert.view, below: bundleidTitle, constant: 5)
		
		let uuidTitle = addLabelToAlert(text: "File Name", bold: true, toView: alert.view, below: lastLabel, constant: 12)
		lastLabel = addLabelToAlert(text: apppath, color:apppathC,toView: alert.view, below: uuidTitle, constant: 5)
		
		let dateTitle = addLabelToAlert(text: "Date Added", bold: true, toView: alert.view, below: lastLabel, constant: 12)
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
		let dateString = dateFormatter.string(from: appdateadded)
		lastLabel = addLabelToAlert(text: dateString, toView: alert.view, below: dateTitle, constant: 5)
		
		let iconTitle = addLabelToAlert(text: "Icon File Name", bold: true, toView: alert.view, below: lastLabel, constant: 12)
		lastLabel = addLabelToAlert(text: iconurl, color:apppathC,toView: alert.view, below: iconTitle, constant: 5)

		alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
		self.present(alert, animated: true, completion: nil)
	}
	
	func addLabelToAlert(text: String, bold: Bool = false, color: UIColor = .label, toView: UIView, below: UIView?, constant: CGFloat) -> UILabel {
		let label = UILabel()
		label.text = text
		
		label.textAlignment = .left
		label.font = bold ? UIFont.boldSystemFont(ofSize: 13) : UIFont.systemFont(ofSize: 13)
		label.textColor = color
		label.numberOfLines = 0
		toView.addSubview(label)
		label.translatesAutoresizingMaskIntoConstraints = false
		
		if let belowView = below {
			label.topAnchor.constraint(equalTo: belowView.bottomAnchor, constant: constant).isActive = true
		} else {
			label.topAnchor.constraint(equalTo: toView.topAnchor, constant: constant).isActive = true
		}
		
		label.leadingAnchor.constraint(equalTo: toView.leadingAnchor, constant: 12).isActive = true
		
		return label
	}

}
