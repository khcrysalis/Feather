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
		case .none: return "archivebox.fill"
		case .ready: return "app.gift"
		case .sendingManifest, .sendingPayload: return "paperplane.fill"
		case .installing: return "square.and.arrow.down"
		case .completed: return "app.badge.checkmark"
		case .broken: return "exclamationmark.triangle.fill"
		}
	}
	
	var statusLabel: String {
		switch status {
		case .none: return .localized("Packaging")
		case .ready: return .localized("Ready")
		case .sendingManifest: return .localized("Sending Manifest")
		case .sendingPayload: return .localized("Sending Payload")
		case .installing: return .localized("Installing")
		case .completed: return .localized("Completed")
		case .broken: return .localized("Error")
		}
	}
}
