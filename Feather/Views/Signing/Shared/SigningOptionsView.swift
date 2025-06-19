//
//  SigningOptionsSharedView.swift
//  Feather
//
//  Created by samara on 15.04.2025.
//

import SwiftUI
import NimbleViews

// MARK: - View
struct SigningOptionsView: View {
	@Binding var options: Options
	var temporaryOptions: Options?
	
	// MARK: Body
	var body: some View {
		if (temporaryOptions == nil) {
			NBSection(.localized("Protection")) {
				_toggle(.localized("PPQ Protection"),
						systemImage: "shield.fill",
						isOn: $options.ppqProtection,
						temporaryValue: temporaryOptions?.ppqProtection
				)
				#warning("add dynamic protect (itunes api)")
//				_toggle("Dynamic Protection",
//						systemImage: "shield.lefthalf.filled",
//						isOn: $options.dynamicProtection,
//						temporaryValue: temporaryOptions?.dynamicProtection
//				)
//					.disabled(!options.ppqProtection)
			} footer: {
				Text(.localized("Enabling any protection will append a random string to the bundleidentifiers of the apps you sign, this is to ensure your Apple ID does not get flagged by Apple. However, when using a signing service you can ignore this."))
			}
		} else {
			NBSection(.localized("General")) {
				Self.picker(.localized("Appearance"),
							systemImage: "paintpalette",
							selection: $options.appAppearance,
							values: Options.appAppearanceValues,
							id: \.description
				)
				
				Self.picker(.localized("Minimum Requirement"),
							systemImage: "ruler",
							selection: $options.minimumAppRequirement,
							values: Options.appMinimumAppRequirementValues,
							id: \.description
				)
			}
			
			Section {
				Self.picker(.localized("Signing Type"),
							systemImage: "signature",
							selection: $options.signingOption,
							values: Options.signingOptionValues,
							id: \.description
				)
			} footer: {
				Text(.localized("Default:\nSigns an application with your specified certificate.\n\nAdhoc (Advanced):\nSigns with no identity, however this unfortunately strips entitlements (iOS won't install this type)."))
			}
		}
		
		NBSection(.localized("App Features")) {
			_toggle(.localized("File Sharing"),
					systemImage: "folder.badge.person.crop",
					isOn: $options.fileSharing,
					temporaryValue: temporaryOptions?.fileSharing
			)
			
			_toggle(.localized("iTunes File Sharing"),
					systemImage: "music.note.list",
					isOn: $options.itunesFileSharing,
					temporaryValue: temporaryOptions?.itunesFileSharing
			)
			
			_toggle(.localized("Pro Motion"),
					systemImage: "speedometer",
					isOn: $options.proMotion,
					temporaryValue: temporaryOptions?.proMotion
			)
			
			_toggle(.localized("Game Mode"),
					systemImage: "gamecontroller",
					isOn: $options.gameMode,
					temporaryValue: temporaryOptions?.gameMode
			)
			
			_toggle(.localized("iPad Fullscreen"),
					systemImage: "ipad.landscape",
					isOn: $options.ipadFullscreen,
					temporaryValue: temporaryOptions?.ipadFullscreen
			)
		}
		
		NBSection(.localized("Removal")) {
			_toggle(.localized("Remove Supported Devices"),
					systemImage: "iphone.slash",
					isOn: $options.removeSupportedDevices,
					temporaryValue: temporaryOptions?.removeSupportedDevices
			)
			
			_toggle(.localized("Remove URL Scheme"),
					systemImage: "ellipsis.curlybraces",
					isOn: $options.removeURLScheme,
					temporaryValue: temporaryOptions?.removeURLScheme
			)
			
			_toggle(.localized("Remove Provisioning"),
					systemImage: "doc.badge.gearshape",
					isOn: $options.removeProvisioning,
					temporaryValue: temporaryOptions?.removeProvisioning
			)
		}
		
		Section {
			_toggle(.localized("Force Localize"),
					systemImage: "character.bubble",
					isOn: $options.changeLanguageFilesForCustomDisplayName,
					temporaryValue: temporaryOptions?.changeLanguageFilesForCustomDisplayName
			)
		} footer: {
			Text(.localized("By default, localized titles for the app won't be changed, however this option overrides it."))
		}
		
		NBSection(.localized("Experiments")) {
			_toggle(.localized("Replace Substrate with ElleKit"),
					systemImage: "pencil",
					isOn: $options.experiment_replaceSubstrateWithEllekit,
					temporaryValue: temporaryOptions?.experiment_replaceSubstrateWithEllekit
			)
			
			_toggle(.localized("Enable Liquid Glass"),
					systemImage: "26.circle",
					isOn: $options.experiment_supportLiquidGlass,
					temporaryValue: temporaryOptions?.experiment_supportLiquidGlass
			)
		} footer: {
			Text(.localized("This option force converts apps to try to use the new liquid glass redesign iOS 26 introduced, this may not work for all applications due to differing frameworks."))
		}
	}
	
	@ViewBuilder
	static func picker<SelectionValue, T>(
		_ title: String,
		systemImage: String,
		selection: Binding<SelectionValue>,
		values: [T],
		id: KeyPath<T, SelectionValue>
	) -> some View where SelectionValue: Hashable {
		Picker(selection: selection) {
			ForEach(values, id: id) { value in
				Text(String(describing: value))
			}
		} label: {
			Label(title, systemImage: systemImage)
		}
	}
	
	@ViewBuilder
	private func _toggle(
		_ title: String,
		systemImage: String,
		isOn: Binding<Bool>,
		temporaryValue: Bool? = nil
	) -> some View {
		Toggle(isOn: isOn) {
			Label {
				if let tempValue = temporaryValue, tempValue != isOn.wrappedValue {
					Text(title).bold()
				} else {
					Text(title)
				}
			} icon: {
				Image(systemName: systemImage)
			}
		}
	}
}
