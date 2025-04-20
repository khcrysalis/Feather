//
//  SigningOptionsSharedView.swift
//  Feather
//
//  Created by samara on 15.04.2025.
//

import SwiftUI

struct SigningOptionsSharedView: View {
	@Binding var options: Options
	var temporaryOptions: Options?
	
	var body: some View {
		Group {
			if (temporaryOptions == nil) {
				FRSection("Protection") {
					_toggle("PPQ Protection",
							systemImage: "shield.fill",
							isOn: $options.ppqProtection,
							temporaryValue: temporaryOptions?.ppqProtection
					)
					
					_toggle("Dynamic Protection",
							systemImage: "shield.lefthalf.filled",
							isOn: $options.dynamicProtection,
							temporaryValue: temporaryOptions?.dynamicProtection
					)
					.disabled(!options.ppqProtection)
				} footer: {
					Text(
					  """
					  Enabling any protection will append a random string to the bundleidentifiers of the apps you sign, this is to ensure your Apple ID does not get flagged by Apple. However, when using a signing service you can ignore this.
					  
					  Dynamic protection will only apply the random string to apps found on the App Store, as a caveat this requires an internet connection.
					  """
					)
				}
			} else {
				FRSection("General") {
					_picker(
						"Appearance",
						systemImage: "paintpalette",
						selection: $options.appAppearance,
						values: Options.appAppearanceValues,
						id: \.description
					)
					
					_picker(
						"Minimum Requirement",
						systemImage: "ruler",
						selection: $options.minimumAppRequirement,
						values: Options.appMinimumAppRequirementValues,
						id: \.description
					)
				}
			}
			
			FRSection("App Features") {
				_toggle("File Sharing",
						systemImage: "folder.badge.person.crop",
						isOn: $options.fileSharing,
						temporaryValue: temporaryOptions?.fileSharing
				)
				
				_toggle("iTunes File Sharing",
						systemImage: "music.note.list",
						isOn: $options.itunesFileSharing,
						temporaryValue: temporaryOptions?.itunesFileSharing
				)
				
				_toggle("ProMotion",
						systemImage: "speedometer",
						isOn: $options.proMotion,
						temporaryValue: temporaryOptions?.proMotion
				)
				
				_toggle("Game Mode",
						systemImage: "gamecontroller",
						isOn: $options.gameMode,
						temporaryValue: temporaryOptions?.gameMode
				)
				
				_toggle("iPad Fullscreen",
						systemImage: "ipad.landscape",
						isOn: $options.ipadFullscreen,
						temporaryValue: temporaryOptions?.ipadFullscreen
				)
			}
			
			FRSection("Removal") {
				_toggle("Remove Supported Devices",
						systemImage: "iphone.slash",
						isOn: $options.removeSupportedDevices,
						temporaryValue: temporaryOptions?.removeSupportedDevices
				)
				
				_toggle("Remove URL Scheme",
						systemImage: "ellipsis.curlybraces",
						isOn: $options.removeURLScheme,
						temporaryValue: temporaryOptions?.removeURLScheme
				)
				
				_toggle("Remove Provisioning",
						systemImage: "doc.badge.gearshape",
						isOn: $options.removeProvisioning,
						temporaryValue: temporaryOptions?.removeProvisioning
				)
				
				_toggle("Remove Watch Placeholder",
						systemImage: "applewatch.slash",
						isOn: $options.removeWatchPlaceholder,
						temporaryValue: temporaryOptions?.removeWatchPlaceholder
				)
			}
			
			FRSection("Display Options") {
				_toggle("Force Localize",
						systemImage: "character.bubble",
						isOn: $options.changeLanguageFilesForCustomDisplayName,
						temporaryValue: temporaryOptions?.changeLanguageFilesForCustomDisplayName
				)
			}
			
			FRSection("Advanced") {
				_toggle("Adhoc Signing",
						systemImage: "signature",
						isOn: $options.doAdhocSigning,
						temporaryValue: temporaryOptions?.doAdhocSigning
				)
			}
		}
	}
	
	@ViewBuilder
	private func _picker<SelectionValue, T>(
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
