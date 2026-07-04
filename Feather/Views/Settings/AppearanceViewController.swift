//
//  AppearanceViewController.swift
//  Feather
//
//  Created by samsam on 5/24/26.
//
import UIKit

private struct _Icon: Identifiable {
	var displayName: String
	var key: String?
	var image: UIImage
	var id: String { key ?? displayName }
	
	init(displayName: String, key: String? = nil) {
		self.displayName = displayName
		self.key = key
		self.image = _altImage(key)
	}
}

fileprivate func _altImage(_ name: String?) -> UIImage {
	let path = Bundle.main.bundleURL.appendingPathComponent((name ?? "AppIcon60x60") + "@2x.png")
	return UIImage(contentsOfFile: path.path) ?? UIImage()
}

final class AppearanceViewController: ThemedTableViewController {
	var currentIcon: String? = UIApplication.shared.alternateIconName
	
	private static let defaultTintColor = UIColor(red: 132/255.0, green: 142/255.0, blue: 249/255.0, alpha: 1.0)
	private var isCustomTintActive = false
	
	private let icons: [_Icon] = [
		.init(displayName: "Current"),
		.init(displayName: "Pinky", key: "V2Mac"),
		.init(displayName: "Classic", key: "V0"),
		.init(displayName: "Donator", key: "Donor"),
		.init(displayName: "Wing", key: "Wing"),
	]
	
	private enum SectionType {
		case colors, customTintOptions, appInfo, icons
		
		var headerTitle: String? {
			switch self {
			case .colors: return "Colors"
			case .icons:  return "Icons"
			default:      return nil
			}
		}
	}
	
	private var activeSections: [SectionType] {
		isCustomTintActive ? [.colors, .customTintOptions, .appInfo, .icons] : [.colors, .appInfo, .icons]
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		title = "Appearance"
		isCustomTintActive = calculateIsCustomTintActive()
	}
	
	private func calculateIsCustomTintActive() -> Bool {
		guard let data = UserDefaults.standard.data(forKey: "Feather.userTintColor"),
			  let color = try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: data) else {
			return false
		}
		return color != Self.defaultTintColor
	}
}

extension AppearanceViewController {
	override func numberOfSections(in tableView: UITableView) -> Int {
		activeSections.count
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch activeSections[section] {
		case .colors:            2
		case .customTintOptions: 1
		case .appInfo:           3
		case .icons:            icons.count
		}
	}
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		activeSections[section].headerTitle
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
		var content = cell.defaultContentConfiguration()
		cell.accessoryView = nil
		cell.accessoryType = .none
		
		switch activeSections[indexPath.section] {
		case .colors:
			if indexPath.row == 0 {
				content.text = "Appearance"
				let styles = UIUserInterfaceStyle.allCases
				let segmented = UISegmentedControl(items: styles.map { $0.label })
				let raw = UserDefaults.standard.integer(forKey: "Feather.userInterfaceStyle")
				segmented.selectedSegmentIndex = styles.firstIndex(of: UIUserInterfaceStyle(rawValue: raw) ?? .unspecified) ?? 0
				segmented.addTarget(self, action: #selector(_didChangeStyle), for: .valueChanged)
				cell.accessoryView = segmented
			} else {
				content.text = "Tint Color"
				cell.accessoryType = .disclosureIndicator
			}
			
		case .customTintOptions:
			content.text = "Reset to Default"
			content.textProperties.color = .systemRed
			
		case .appInfo:
			if indexPath.row == 0 {
				content.text = Bundle.main.name
				content.secondaryText = "\(Bundle.main.version) • \(Bundle.main.bundleIdentifier!)"
				content.image = iconTest(Bundle.main.bundleURL)
				content.imageProperties.maximumSize = CGSize(width: 45, height: 45)
				content.imageProperties.cornerRadius = 10
			} else {
				let isDynamic = indexPath.row == 1
				content.text = isDynamic ? "Dynamic Icons" : "Tint Icons"
				let toggle = UISwitch()
				toggle.isOn = UserDefaults.standard.bool(forKey: isDynamic ? "Feather.shouldChangeIconsBasedOffStyle" : "Feather.shouldTintIcons")
				toggle.addTarget(self, action: isDynamic ? #selector(_dynamicIconsChanged) : #selector(_tintedIconsChanged), for: .valueChanged)
				cell.accessoryView = toggle
			}
			
		case .icons:
			let icon = icons[indexPath.row]
			content.text = icon.displayName
			content.image = icon.image
			content.imageProperties.maximumSize = CGSize(width: 45, height: 45)
			content.imageProperties.cornerRadius = 10
			cell.accessoryType = (icon.key == currentIcon) ? .checkmark : .none
		}
		
		cell.contentConfiguration = content
		return cell
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		
		switch activeSections[indexPath.section] {
		case .colors where indexPath.row == 1:
			_openColorWheel()
		case .customTintOptions:
			_resetToDefaultTint()
		case .icons:
			let icon = icons[indexPath.row]
			UIApplication.shared.setAlternateIconName(icon.key) { [weak self] _ in
				DispatchQueue.main.async {
					self?.currentIcon = UIApplication.shared.alternateIconName
					self?._reloadIconPreview()
				}
			}
		default:
			break
		}
	}
}

extension AppearanceViewController {
	@objc private func _didChangeStyle(_ sender: UISegmentedControl) {
		let style = UIUserInterfaceStyle.allCases[sender.selectedSegmentIndex]
		UserDefaults.standard.set(style.rawValue, forKey: "Feather.userInterfaceStyle")
		view.window?.overrideUserInterfaceStyle = style
		_reloadIconPreview()
	}
	
	@objc private func _openColorWheel() {
		let vc = UIColorPickerViewController()
		if 
			let data = UserDefaults.standard.data(forKey: "Feather.userTintColor"),
			let color = try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: data) 
		{
			vc.selectedColor = color
		}
		vc.delegate = self
		present(vc, animated: true)
	}
	
	@objc private func _dynamicIconsChanged(_ sender: UISwitch) {
		UserDefaults.standard.set(sender.isOn, forKey: "Feather.shouldChangeIconsBasedOffStyle")
		_reloadIconPreview()
	}
	
	@objc private func _tintedIconsChanged(_ sender: UISwitch) {
		UserDefaults.standard.set(sender.isOn, forKey: "Feather.shouldTintIcons")
		_reloadIconPreview()
	}
	
	private func _resetToDefaultTint() {
		if let data = try? NSKeyedArchiver.archivedData(withRootObject: Self.defaultTintColor, requiringSecureCoding: true) {
			UserDefaults.standard.set(data, forKey: "Feather.userTintColor")
		}
		
		view.window?.tintColor = Self.defaultTintColor
		_updateLayoutStructure()
	}
	
	private func _updateLayoutStructure() {
		let updatedState = calculateIsCustomTintActive()
		guard isCustomTintActive != updatedState else {
			_reloadIconPreview()
			return
		}
		
		isCustomTintActive = updatedState
		
		tableView.performBatchUpdates({
			if updatedState {
				tableView.insertSections(IndexSet(integer: 1), with: .bottom)
			} else {
				tableView.deleteSections(IndexSet(integer: 1), with: .bottom)
			}
		}, completion: { [weak self] _ in
			self?._reloadIconPreview()
		})
	}
	
	private func _reloadIconPreview() {
		if let appInfoIndex = activeSections.firstIndex(of: .appInfo) {
			tableView.reloadRows(at: [IndexPath(row: 0, section: appInfoIndex)], with: .automatic)
		}
	}
}

extension AppearanceViewController: UIColorPickerViewControllerDelegate {
	func colorPickerViewController(_ viewController: UIColorPickerViewController, didSelect color: UIColor, continuously: Bool) {
		if let data = try? NSKeyedArchiver.archivedData(
			withRootObject: color, 
			requiringSecureCoding: true
		) {
			UserDefaults.standard.set(data, forKey: "Feather.userTintColor")
		}
		
		view.window?.tintColor = color
		_updateLayoutStructure()
	}
}
