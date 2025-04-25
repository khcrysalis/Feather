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
	
	@ObservedObject var viewModel: StatusViewModel
	
	init(viewModel: StatusViewModel) {
		self.viewModel = viewModel
	}
	
	func install(at url: URL) async throws {
		var afcClient: AfcClientHandle?
		var fileHandle: AfcFileHandle?
		var installproxy: InstallationProxyClientHandle?
		
		try await Task.detached(priority: .userInitiated) {
			guard await afc_client_connect_tcp(self._heartbeat.provider, &afcClient) == IdeviceSuccess else {
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
				try await self._updateProgress(with: progress)
			}
			
			guard afc_file_close(fileHandle) == IdeviceSuccess else {
				throw ConduitInstallerError.missingFileHandle
			}
			
			try await self._updateStatus(with: .installing)
			
			guard await installation_proxy_connect_tcp(self._heartbeat.provider, &installproxy) == IdeviceSuccess else {
				throw ConduitInstallerError.unableToCreateStaging
			}
			
			let installError = remoteDir.withCString { cString in
				installation_proxy_install(installproxy, cString, nil)
			}
			
			guard installError == IdeviceSuccess else {
				throw ConduitInstallerError.unableToInstall
			}
			
			try await self._updateStatus(with: .completed(.success(())))
		}.value
	}
	
	private func _updateStatus(with status: InstallerStatus) async throws {
		await MainActor.run {
			self.viewModel.status = status
		}
	}
	
	private func _updateProgress(with status: Double) async throws {
		await MainActor.run {
			self.viewModel.uploadProgress = status
		}
	}
}

private enum ConduitInstallerError: Error {
	case cannotConnectToAFC
	case unableToCreateStaging
	case writeErrorAFC
	case missingFileHandle
	case unableToInstall
}
