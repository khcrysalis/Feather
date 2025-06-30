//
//  StatusViewModel.swift
//  Feather
//
//  Created by samara on 24.04.2025.
//

import Foundation
import Combine
import IDeviceSwift

extension InstallerStatusViewModel {
	var statusImage: String {
		switch status {
		case .none: "archivebox.fill"
		case .ready: "app.gift"
		case .sendingManifest, .sendingPayload: "paperplane.fill"
		case .installing: "square.and.arrow.down"
		case .completed: "app.badge.checkmark"
		case .broken: "exclamationmark.triangle.fill"
		}
	}
	
	var statusLabel: String {
		switch status {
		case .none: .localized("Packaging")
		case .ready: .localized("Ready")
		case .sendingManifest: .localized("Sending Manifest")
		case .sendingPayload: .localized("Sending Payload")
		case .installing: .localized("Installing")
		case .completed: .localized("Completed")
		case .broken: .localized("Error")
		}
	}
}
