//
//  StatusViewModel.swift
//  Feather
//
//  Created by samara on 24.04.2025.
//

import Foundation
import Combine

final class InstallerStatusViewModel: ObservableObject {
	@Published var status: InstallerStatus
	
	@Published var uploadProgress: Double = 0.0
	@Published var packageProgress: Double = 0.0
	@Published var installProgress: Double = 0.0
	
	var overallProgress: Double {
		#if IDEVICE
		(installProgress + uploadProgress + packageProgress) / 3.0
		#elseif SERVER
		packageProgress
		#endif
	}
	
	var isCompleted: Bool {
		if case .completed = status {
			return true
		}
		return false
	}
	
	init(status: InstallerStatus = .none) {
		self.status = status
	}
	
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
		case .none: return "Packaging"
		case .ready: return "Ready"
		case .sendingManifest: return "Sending Manifest"
		case .sendingPayload: return "Sending Payload"
		case .installing: return "Installing"
		case .completed: return "Completed"
		case .broken: return "Error"
		}
	}
}

enum InstallerStatus {
	case none
	case ready
	case sendingManifest
	case sendingPayload
	case installing
	case completed(Result<Void, Error>)
	case broken(Error)
}
