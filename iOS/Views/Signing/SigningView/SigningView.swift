//
//  SigningsViewController.swift
//  feather
//
//  Created by samara on 25.10.2024.
//

import UIKit
import SwiftUI
import CoreData

struct SigningView: View {
	private var isSigning: Bool
	private var application: NSManagedObject?
	private var appsViewController: LibraryViewController?
	
	@ObservedObject var signingDataWrapper: SigningDataWrapper
	@State var mainOptions = MainSigningOptions()
	
	init(sign: Bool, signingDataWrapper: SigningDataWrapper, application: NSManagedObject? = nil, appsViewController: LibraryViewController? = nil) {
		self.isSigning = sign
		self.signingDataWrapper = signingDataWrapper
		self.application = application
		self.appsViewController = appsViewController
	}
	
	var body: some View {
		if isSigning {
			NavigationView {
				viewbody.listStyle(.sidebar)
			}
		} else {
			viewbody.listStyle(.insetGrouped)
		}
	}
	
	private var viewbody: some View {
		List {
			Section {				
				topBody
			}
			
			ForEach(toggleOptions, id: \.title) { option in
				Section {
					Toggle(option.title, isOn: option.binding)
				} footer: {
					Text(option.footer ?? "")
				}
			}
		}
		.navigationTitle("Signing Options")
		.navigationBarTitleDisplayMode(.inline)
	}
	
	@ViewBuilder
	private var topBody: some View {
		if isSigning {
			Text("signing shit")
		} else {
			Toggle("Enable Protections", isOn: $signingDataWrapper.signingOptions.ppqCheckProtection)

			NavigationLink(destination: IdentifiersView(signingDataWrapper: signingDataWrapper)) {
				Text("Bundle Identifiers")
					.foregroundColor(signingDataWrapper.signingOptions.ppqCheckProtection ? .gray : .primary)
			}
			.disabled(signingDataWrapper.signingOptions.ppqCheckProtection)
			
			Toggle("Install after Signing", isOn: $signingDataWrapper.signingOptions.installAfterSigned)
			
			NavigationLink(destination: AddTweaksView()) {
				Text("Add Default Tweaks")
			}
		}
	}
	
	private var toggleOptions: [ToggleOption] {
		[
			ToggleOption(
				title: "Remove all PlugIns",
				footer: "Removes the PlugIns directory inside of the app, which would usually have some components for the app to function properly.",
				binding: $signingDataWrapper.signingOptions.removePlugins
			),
			ToggleOption(
				title: "Force File Sharing",
				footer: "Allows other apps to open and edit the files stored in the Documents folder. This option also lets users set the app’s default save location in Settings.",
				binding: $signingDataWrapper.signingOptions.forceFileSharing
			),
			ToggleOption(
				title: "Remove UISupportedDevices",
				footer: "Removes device restrictions for the application.",
				binding: $signingDataWrapper.signingOptions.removeSupportedDevices
			),
			ToggleOption(
				title: "Remove URL Scheme",
				footer: "Removes any possible URL schemes (i.e. 'feather://')",
				binding: $signingDataWrapper.signingOptions.removeURLScheme
			),
			ToggleOption(
				title: "Enable ProMotion",
				footer: "Enables ProMotion capabilities within the app, however on lower versions of 15.x this may not be enough.",
				binding: $signingDataWrapper.signingOptions.forceProMotion
			),
			ToggleOption(
				title: "Force Full Screen",
				footer: "Forces only fullscreen capabilities within iPad apps, disallowing sharing the screen with other apps. On an external screen, the window for an app with this setting maintains its canvas size.",
				binding: $signingDataWrapper.signingOptions.forceForceFullScreen
			),
			ToggleOption(
				title: "Force iTunes File Sharing",
				footer: "Forces the app to share their documents directory, allowing sharing between iTunes and Finder.",
				binding: $signingDataWrapper.signingOptions.forceiTunesFileSharing
			),
			ToggleOption(
				title: "Force Try To Localize",
				footer: "Forces localization by modifying every localizable bundle within the app when trying to change a name of the app.",
				binding: $signingDataWrapper.signingOptions.forceTryToLocalize
			),
			ToggleOption(
				title: "Remove Provisioning File",
				footer: "Removes .mobileprovison from appearing in your app after signing.",
				binding: $signingDataWrapper.signingOptions.removeProvisioningFile
			),
			ToggleOption(
				title: "Remove Watch Placeholder",
				footer: "Removes unwanted watch placeholder which isn't supposed to be there, present in apps such as YouTube music, etc.",
				binding: $signingDataWrapper.signingOptions.removeWatchPlaceHolder
			)
		]
	}
}

struct ToggleOption {
	let title: String
	let footer: String?
	let binding: Binding<Bool>
}
