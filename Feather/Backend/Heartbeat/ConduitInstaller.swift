//
//  ConduitInstaller.swift
//  Feather
//
//  Created by samara on 23.04.2025.
//

import Foundation
import SwiftUICore

class ConduitInstaller: Identifiable, ObservableObject {
	private let _heartbeat = HeartbeatManager.shared
	private let _uuid = UUID().uuidString
	
	typealias AfcClientHandle = OpaquePointer
	typealias AfcFileHandle = OpaquePointer
	typealias InstallationProxyClientHandle = OpaquePointer
	
	@ObservedObject var viewModel: InstallerStatusViewModel
	
	init(viewModel: InstallerStatusViewModel) {
		self.viewModel = viewModel
	}
	
	func install(at url: URL) async throws {
		var afcClient: AfcClientHandle?
		var fileHandle: AfcFileHandle?
		var installproxy: InstallationProxyClientHandle?
		
		try await Task.detached(priority: .userInitiated) {
			guard FileManager.default.fileExists(atPath: HeartbeatManager.pairingFile()) else {
				throw ConduitInstallerError.missingPairing
			}
			
			guard await self._heartbeat.checkSocketConnection().isConnected else {
				throw ConduitInstallerError.missingPairing
			}
			
			defer {
				afc_client_free(afcClient)
				installation_proxy_client_free(installproxy)
			}
			
			let heartbeat = await self._heartbeat
			guard let provider = heartbeat.provider else {
				throw ConduitInstallerError.cannotConnectToAFC
			}
			
			guard afc_client_connect_tcp(provider, &afcClient) == IdeviceSuccess else {
				throw ConduitInstallerError.cannotConnectToAFC
			}
			
			let stagingDir = "PublicStaging"
			
			guard afc_make_directory(afcClient, stagingDir) == IdeviceSuccess else {
				throw ConduitInstallerError.unableToCreateStaging
			}
			
			let remoteDir = "/\(stagingDir)/\(self._uuid).ipa"
			
			guard afc_file_open(afcClient, remoteDir, AfcWrOnly, &fileHandle) == IdeviceSuccess else {
				throw ConduitInstallerError.unableToCreateStaging
			}
			
			try await self._updateStatus(with: .sendingPayload)
			
			guard let fileHandle = fileHandle else {
				throw ConduitInstallerError.missingFileHandle
			}

			let data = try Data(contentsOf: url)
			let totalSize = data.count
			let chunkSize = 64 * 1024 // 64kb
			var totalBytesWritten = 0
			
			guard let rawBuffer = data.withUnsafeBytes({ $0.baseAddress })?.assumingMemoryBound(to: UInt8.self) else {
				throw ConduitInstallerError.writeErrorAFC
			}
			
			while totalBytesWritten < totalSize {
				let bytesLeft = totalSize - totalBytesWritten
				let bytesToWrite = min(chunkSize, bytesLeft)
				let writePtr = rawBuffer.advanced(by: totalBytesWritten)
				
				let result = afc_file_write(fileHandle, writePtr, bytesToWrite)
				if result != IdeviceSuccess {
					throw ConduitInstallerError.writeErrorAFC
				}
				
				totalBytesWritten += bytesToWrite
				
				let progress = Double(totalBytesWritten) / Double(totalSize)
				try await self._updateUploadProgress(with: progress)
			}
			
			guard afc_file_close(fileHandle) == IdeviceSuccess else {
				throw ConduitInstallerError.missingFileHandle
			}
			
			try await self._updateStatus(with: .installing)
			
			guard installation_proxy_connect_tcp(provider, &installproxy) == IdeviceSuccess else {
				throw ConduitInstallerError.unableToCreateStaging
			}
			
			let installError: IdeviceErrorCode = remoteDir.withCString { cString in
				let context = Unmanaged.passUnretained(self).toOpaque()
				
				return installation_proxy_install_with_callback(
					installproxy,
					cString,
					nil, // options
					Self._installationProgressCallback,
					context
				)
			}
			
			guard installError == IdeviceSuccess else {
				throw ConduitInstallerError.unableToInstall
			}
			
			try await Task.sleep(nanoseconds: 350_000_000)
			try await self._updateStatus(with: .completed(.success(())))
		}.value
	}
	
	private func _updateStatus(with status: InstallerStatus) async throws {
		await MainActor.run {
			self.viewModel.status = status
		}
	}
	
	private func _updateUploadProgress(with status: Double) async throws {
		await MainActor.run {
			self.viewModel.uploadProgress = status
		}
	}
	
	nonisolated
	static private let _installationProgressCallback: @convention(c) (
		UInt64,
		UnsafeMutableRawPointer?
	) -> Void = { progress, context in
		guard let context = context else { return }
		let installer = Unmanaged<ConduitInstaller>.fromOpaque(context).takeUnretainedValue()
		Task {
			try? await installer._updateInstallProgress(with: Double(progress) / 100.0)
		}
	}
	
	private func _updateInstallProgress(with status: Double) async throws {
		await MainActor.run {
			self.viewModel.installProgress = status
		}
	}
}

private enum ConduitInstallerError: Error, LocalizedError {
	case missingPairing
	case cannotConnectToAFC
	case unableToCreateStaging
	case writeErrorAFC
	case missingFileHandle
	case unableToInstall
	
	var errorDescription: String? {
		switch self {
		case .missingPairing:
			return "Unable to connect to TCP. Make sure you have loopback VPN enabled and you are on WiFi or Airplane mode."
		case .cannotConnectToAFC:
			return "Cannot connect to AFC (Apple File Conduit)."
		case .unableToCreateStaging:
			return "Unable to create the staging directory."
		case .writeErrorAFC:
			return "Error writing to AFC."
		case .missingFileHandle:
			return "Missing file handle for AFC operation."
		case .unableToInstall:
			return "Unable to install specified application. Please check if your app is signed properly and not already installed onto your device with a different certificate."
		}
	}
}
