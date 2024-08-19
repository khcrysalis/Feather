//
//  DylibHandler.swift
//  feather
//
//  Created by samara on 8/17/24.
//

import Foundation
import SWCompression

class TweakHandler {
	enum FileProcessingError: Error {
		case unsupportedFileExtension(String)
	}

	static func getInputFiles(urls: [URL], app: URL) throws {
		guard !urls.isEmpty else {
			Debug.shared.log(message: "No dylibs to inject, skipping!")
			return
		}
		
		try createDirectoryIfNeeded(at: app.appendingPathComponent("Frameworks"))
		
		Debug.shared.log(message: "Attempting to inject...")
		
		let fileManager = FileManager.default
		let baseTmpDir = fileManager.temporaryDirectory.appendingPathComponent(UUID().uuidString)
		
		try fileManager.createDirectory(at: baseTmpDir, withIntermediateDirectories: true, attributes: nil)
		
		for url in urls {
			try handleFile(url: url, baseTmpDir: baseTmpDir, app: app)
		}
	}

	static func handleFile(url: URL, baseTmpDir: URL, app: URL) throws {
		let fileExtension = url.pathExtension.lowercased()
		
		switch fileExtension {
		case "dylib", "framework":
			do {
				try handleSpecificFile(url: url, baseTmpDir: baseTmpDir, app: app)
			} catch {
				Debug.shared.log(message: "Error handling file \(url): \(error)")
				throw error
			}
		case "deb":
			let uniqueSubDir = baseTmpDir.appendingPathComponent(UUID().uuidString)
			let fileManager = FileManager.default
			try fileManager.createDirectory(at: uniqueSubDir, withIntermediateDirectories: true, attributes: nil)
			
			Debug.shared.log(message: "Extracting file: \(url) into \(uniqueSubDir.path)")
			
			do {
				let debData = try Data(contentsOf: url)
				let arFiles = try extractAR(debData)
				
				for arFile in arFiles {
					let outputPath = uniqueSubDir.appendingPathComponent(arFile.name)
					try arFile.content.write(to: outputPath)
					Debug.shared.log(message: "Extracted \(arFile.name) to \(outputPath.path)")
					
					if ["data.tar.lzma", "data.tar.gz", "data.tar.xz", "data.tar.bz2"].contains(arFile.name) {
						var fileToProcess = outputPath
						try processFile(at: &fileToProcess)
						try processFile(at: &fileToProcess)
						try handleExtractedDirectory(url: fileToProcess, app: app)
					}
				}
			} catch {
				Debug.shared.log(message: "Error handling file \(url): \(error)")
				throw error
			}
			
		default:
			Debug.shared.log(message: "Unsupported file extension: \(fileExtension)")
			throw FileProcessingError.unsupportedFileExtension(fileExtension)
		}
	}
	
	static func handleSpecificFile(url: URL, baseTmpDir: URL, app: URL) throws {
		let fileExtension = url.pathExtension.lowercased()
		switch fileExtension {
		case "dylib":
			let destinationURL = app.appendingPathComponent("Frameworks").appendingPathComponent(url.lastPathComponent)
			try moveFile(from: url, to: destinationURL)
			if let executableURL = try findExecutable(at: destinationURL) {
				Debug.shared.log(message: "Executable path: \(executableURL)")
			}
			Debug.shared.log(message: "Dylib file path: \(destinationURL)")
		case "framework":
			let destinationURL = app.appendingPathComponent("Frameworks").appendingPathComponent(url.lastPathComponent)
			try moveFile(from: url, to: destinationURL)
			if let executableURL = try findExecutable(at: destinationURL) {
				Debug.shared.log(message: "Executable path: \(executableURL)")
			}
			Debug.shared.log(message: "Framework file path: \(destinationURL)")
		case "appex":
			let destinationURL = app.appendingPathComponent("PlugIns").appendingPathComponent(url.lastPathComponent)
			try moveFile(from: url, to: destinationURL)
		case "bundle":
			let destinationURL = app.appendingPathComponent(url.lastPathComponent)
			try moveFile(from: url, to: destinationURL)
		default:
			Debug.shared.log(message: "Unsupported file extension: \(fileExtension)")
			throw FileProcessingError.unsupportedFileExtension(fileExtension)
		}
	}
	
	static func handleExtractedDirectory(url: URL, app: URL) throws {

		let pathsToCheck = [
			url.appendingPathComponent("Library/Frameworks"),
			url.appendingPathComponent("Library/MobileSubstrate/DynamicLibraries"),
			url.appendingPathComponent("Library/Application Support")
		]
		
		for path in pathsToCheck {
			switch path.lastPathComponent {
			case "Frameworks":
				if let fileURL = checkFiles(in: path, extensions: ["framework"]) {
					try handleSpecificFile(url: fileURL, baseTmpDir: url, app: app)
				}
			case "DynamicLibraries":
				if let fileURL = checkFiles(in: path, extensions: ["dylib"]) {
					try handleSpecificFile(url: fileURL, baseTmpDir: url, app: app)
				}
			case "Application Support":
				try checkApplicationSupportFiles(in: path, baseTmpDir: url, app: app)
			default:
				break
			}
		}
		
		Debug.shared.log(message: "Handling of extracted directory complete.")
	}

	private static func checkApplicationSupportFiles(in path: URL, baseTmpDir: URL, app: URL) throws {
		let fileManager = FileManager.default
		if let enumerator = fileManager.enumerator(at: path, includingPropertiesForKeys: [.isDirectoryKey], options: [.skipsHiddenFiles]) {
			for case let directoryURL as URL in enumerator {
				var isDirectory: ObjCBool = false
				if fileManager.fileExists(atPath: directoryURL.path, isDirectory: &isDirectory), isDirectory.boolValue {
					if let fileURL = checkFiles(in: directoryURL, extensions: ["bundle"], isBundleCheck: true) {
						try handleSpecificFile(url: fileURL, baseTmpDir: baseTmpDir, app: app)
					}
					break
				}
			}
		}
	}

	static func checkFiles(in directory: URL, extensions: Set<String>, isBundleCheck: Bool = false) -> URL? {
		let fileManager = FileManager.default
		guard let enumerator = fileManager.enumerator(at: directory, includingPropertiesForKeys: [.isRegularFileKey, .isDirectoryKey], options: [.skipsHiddenFiles]) else {
			return nil
		}
		
		for case let fileURL as URL in enumerator {
			var isDirectory: ObjCBool = false
			if fileManager.fileExists(atPath: fileURL.path, isDirectory: &isDirectory) {
				if isDirectory.boolValue {
					if extensions.contains(fileURL.pathExtension) {
						return fileURL
					}
				} else if extensions.contains(fileURL.pathExtension) {
					return fileURL
				}
			}
		}
		return nil
	}


}


// MARK: - extract deb
extension TweakHandler {
	static func processFile(at packagesFile: inout URL) throws {
		let succeededExtension = packagesFile.pathExtension.lowercased()
		let fileManager = FileManager.default

		switch succeededExtension {
		case "xz":
			let compressedData = try Data(contentsOf: packagesFile)
			let decompressedData = try XZArchive.unarchive(archive: compressedData)
			let outputURL = packagesFile.deletingPathExtension()
			try decompressedData.write(to: outputURL)
			packagesFile = outputURL

		case "lzma":
			let compressedData = try Data(contentsOf: packagesFile)
			let decompressedData = try LZMA.decompress(data: compressedData)
			let outputURL = packagesFile.deletingPathExtension()
			try decompressedData.write(to: outputURL)
			packagesFile = outputURL

		case "bz2":
			let compressedData = try Data(contentsOf: packagesFile)
			let decompressedData = try BZip2.decompress(data: compressedData)
			let outputURL = packagesFile.deletingPathExtension()
			try decompressedData.write(to: outputURL)
			packagesFile = outputURL

		case "gz":
			let compressedData = try Data(contentsOf: packagesFile)
			let decompressedData = try GzipArchive.unarchive(archive: compressedData)
			let outputURL = packagesFile.deletingPathExtension()
			try decompressedData.write(to: outputURL)
			packagesFile = outputURL

		case "tar":
			let tarData = try Data(contentsOf: packagesFile)
			let tarContainer = try TarContainer.open(container: tarData)

			let extractionDirectory = packagesFile.deletingLastPathComponent().appendingPathComponent(UUID().uuidString)
			try fileManager.createDirectory(at: extractionDirectory, withIntermediateDirectories: true, attributes: nil)

			for entry in tarContainer {
				let entryPath = extractionDirectory.appendingPathComponent(entry.info.name)
				if entry.info.type == .regular {
					try entry.data?.write(to: entryPath)
				} else if entry.info.type == .directory {
					try fileManager.createDirectory(at: entryPath, withIntermediateDirectories: true, attributes: nil)
				}
			}

			packagesFile = extractionDirectory

		default:
			throw FileProcessingError.unsupportedFileExtension(succeededExtension)
		}
	}
}
// MARK: - File management
extension TweakHandler {
	private static func createDirectoryIfNeeded(at url: URL) throws {
		let fileManager = FileManager.default
		if !fileManager.fileExists(atPath: url.path) {
			try fileManager.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
		}
	}
	
	private static func findExecutable(at frameworkURL: URL) throws -> URL? {
		let infoPlistURL = frameworkURL.appendingPathComponent("Info.plist")
		let fileManager = FileManager.default

		guard fileManager.fileExists(atPath: infoPlistURL.path) else {
			Debug.shared.log(message: "Info.plist not found at: \(infoPlistURL)")
			return nil
		}

		let plistData = try Data(contentsOf: infoPlistURL)
		if let plist = try PropertyListSerialization.propertyList(from: plistData, options: [], format: nil) as? [String: Any],
		   let executableName = plist["CFBundleExecutable"] as? String {
			let executableURL = frameworkURL.appendingPathComponent(executableName)
			Debug.shared.log(message: "Executable path: \(executableURL)")
			return executableURL
		} else {
			Debug.shared.log(message: "CFBundleExecutable not found in Info.plist")
			return nil
		}
	}


	private static func moveFile(from sourceURL: URL, to destinationURL: URL) throws {
		let fileManager = FileManager.default
		if fileManager.fileExists(atPath: destinationURL.path) {
			Debug.shared.log(message: "File already exists at destination: \(destinationURL)")
		} else {
			try fileManager.moveItem(at: sourceURL, to: destinationURL)
			Debug.shared.log(message: "Moved file to: \(destinationURL)")
		}
	}
}
