//
//  DylibHandler.swift
//  feather
//
//  Created by samara on 8/17/24.
//  Copyright (c) 2024 Samara M (khcrysalis)
//

import Foundation
import SWCompression

enum FileProcessingError: Error {
	case unsupportedFileExtension(String)
	case decompressionFailed(String)
	case missingFile(String)
}

class TweakHandler {
	
	let fileManager = FileManager.default
	
	private var urls: [String]
	private let app: URL
	private var urlsToInject: [URL] = []
	private var directoriesToCheck: [URL] = []

	init(urls: [String], app: URL) {
		self.urls = urls
		self.app = app
	}

	public func getInputFiles() throws {
		guard !urls.isEmpty else {
			Debug.shared.log(message: "No dylibs to inject, skipping!")
			return
		}
		
		let frameworksPath = app.appendingPathComponent("Frameworks").appendingPathComponent("CydiaSubstrate.framework")
		if !fileManager.fileExists(atPath: frameworksPath.path) {
			if let ellekitURL = Bundle.main.url(forResource: "ellekit", withExtension: "deb") {
				self.urls.insert(ellekitURL.absoluteString, at: 0)
			} else {
				Debug.shared.log(message: "Error: ellekit.deb not found in the app bundle ⁉️", type: .error)
				return
			}
		}

		let baseTmpDir = fileManager.temporaryDirectory.appendingPathComponent(UUID().uuidString)
		
		do {
			try TweakHandler.createDirectoryIfNeeded(at: app.appendingPathComponent("Frameworks"))
			try TweakHandler.createDirectoryIfNeeded(at: baseTmpDir)
			
			// check for appropriate files, if theres debs
			// it will extract then add a url, if theres no url, i.e.
			// you haven't added a deb, it will skip
			for url in urls {
				let urlf = URL(string: url)
				switch urlf!.pathExtension.lowercased() {
				case "dylib":
					try handleDylib(at: urlf!)
				case "deb":
					try handleDeb(at: urlf!, baseTmpDir: baseTmpDir)
				default:
					Debug.shared.log(message: "Unsupported file type: \(urlf!.lastPathComponent), skipping.")
				}
			}
			
			// check contents of data.tar's extracted from debs
			if !directoriesToCheck.isEmpty {
				try handleDirectories(at: directoriesToCheck)
				if !urlsToInject.isEmpty {
					try handleExtractedDirectoryContents(at: urlsToInject)
				}
			}
			
		} catch {
			throw error
		}
	}
	
	// finally, handle extracted contents
	private func handleExtractedDirectoryContents(at urls: [URL]) throws {
		for url in urls {
			switch url.pathExtension.lowercased() {
			case "dylib":
				try handleDylib(at: url)
			case "framework":
				let destinationURL = app.appendingPathComponent("Frameworks").appendingPathComponent(url.lastPathComponent)
				try TweakHandler.moveFile(from: url, to: destinationURL)
				try handleDylib(framework: destinationURL)
			case "bundle":
				let destinationURL = app.appendingPathComponent(url.lastPathComponent)
				try TweakHandler.moveFile(from: url, to: destinationURL)
			default:
				Debug.shared.log(message: "Unsupported file type: \(url.lastPathComponent), skipping.")
			}
		}
	}
	
	// Inject imported dylib file
	private func handleDylib(at url: URL) throws {
		do {
			let destinationURL = app.appendingPathComponent("Frameworks").appendingPathComponent(url.lastPathComponent)
			try TweakHandler.moveFile(from: url, to: destinationURL)
			
			// change paths because some tweaks hardlink, which is not ideal.
			// this is not a good solution, at most this would work for basic tweaks
			// we recommend you use newer theos to compile, and make sure it works
			// using the ellekit framework
			_ = changeDylib(
				filePath: destinationURL.path,
				oldPath: "/Library/Frameworks/CydiaSubstrate.framework/CydiaSubstrate",
				newPath: "@rpath/CydiaSubstrate.framework/CydiaSubstrate"
			)
			
			// inject if there's a valid app main executable
			if let exe = try TweakHandler.findExecutable(at: app) {
				_ = injectDylib(
					filePath: exe.path,
					dylibPath: "@executable_path/Frameworks/\(destinationURL.lastPathComponent)",
					weakInject: true
				)
			}
		} catch {
			throw error
		}
	}
	
	// Inject imported framework dir
	private func handleDylib(framework: URL) throws {
		do {
			if let fexe = try TweakHandler.findExecutable(at: framework) {
				
				// change paths because some tweaks hardlink, which is not ideal.
				// this is not a good solution, at most this would work for basic tweaks
				// we recommend you use newer theos to compile, and make sure it works
				// using the ellekit framework
				_ = changeDylib(
					filePath: fexe.path,
					oldPath: "/Library/Frameworks/CydiaSubstrate.framework/CydiaSubstrate",
					newPath: "@rpath/CydiaSubstrate.framework/CydiaSubstrate"
				)
				
				// inject if there's a valid app main executable
				if let appexe = try TweakHandler.findExecutable(at: app) {
					_ = injectDylib(
						filePath: appexe.path,
						dylibPath: "@executable_path/Frameworks/\(framework.lastPathComponent)/\(fexe.lastPathComponent)",
						weakInject: true
					)
				}
			}
			
			
		} catch {
			throw error
		}
	}
	
	// Extracy imported deb file
	private func handleDeb(at url: URL, baseTmpDir: URL) throws {
		let uniqueSubDir = baseTmpDir.appendingPathComponent(UUID().uuidString)
		try TweakHandler.createDirectoryIfNeeded(at: uniqueSubDir)
		
		// I don't particularly like this code
		// but it somehow works well enough,
		// do note large lzma's are slow as hell
		do {
			let arFiles = try extractAR(try Data(contentsOf: url))
			
			for arFile in arFiles {
				let outputPath = uniqueSubDir.appendingPathComponent(arFile.name)
				try arFile.content.write(to: outputPath)
				
				if ["data.tar.lzma", "data.tar.gz", "data.tar.xz", "data.tar.bz2"].contains(arFile.name) {
					var fileToProcess = outputPath
					try processFile(at: &fileToProcess)
					try processFile(at: &fileToProcess)
					directoriesToCheck.append(fileToProcess)
				}
			}
		} catch {
			Debug.shared.log(message: "Error handling file \(url): \(error)")
			throw error
		}
	}
	
	// Read extracted deb file, locate all neccessary contents to copy over to the .app
	private func handleDirectories(at urls: [URL]) throws {
		let directoriesToCheck = [
			"Library/Frameworks/", "var/jb/Library/Frameworks/",
			"Library/MobileSubstrate/DynamicLibraries/", "var/jb/Library/MobileSubstrate/DynamicLibraries/",
			"Library/Application Support/", "var/jb/Library/Application Support/"
		]
		
		let fileManager = FileManager.default
		
		for baseURL in urls {
			for directory in directoriesToCheck {
				let directoryURL = baseURL.appendingPathComponent(directory)
				
				guard fileManager.fileExists(atPath: directoryURL.path) else {
					Debug.shared.log(message: "Directory does not exist: \(directoryURL.path). Skipping.")
					continue
				}
				
				switch directory {
				case "Library/MobileSubstrate/DynamicLibraries/", "var/jb/Library/MobileSubstrate/DynamicLibraries/":
					let dylibFiles = try locateDylibFiles(in: directoryURL)
					for fileURL in dylibFiles {
						urlsToInject.append(fileURL)
					}
					
				case "Library/Frameworks/", "var/jb/Library/Frameworks/":
					let frameworkDirectories = try locateFrameworkDirectories(in: directoryURL)
					for frameworkURL in frameworkDirectories {
						urlsToInject.append(frameworkURL)
					}
					
				case "Library/Application Support/", "var/jb/Library/Application Support/":
					try searchForBundles(in: directoryURL)
					
				default:
					Debug.shared.log(message: "Unexpected directory path: \(directoryURL.path)")
				}
			}
		}
	}
}




// MARK: - Find correct files in debs
extension TweakHandler {
	private func searchForBundles(in directory: URL) throws {
		let fileManager = FileManager.default
		let allFiles = try fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])

		let bundleDirectories = allFiles.filter { url in
			let attributes = try? fileManager.attributesOfItem(atPath: url.path)
			let isSymlink = attributes?[.type] as? FileAttributeType == .typeSymbolicLink
			return url.pathExtension.lowercased() == "bundle" && url.hasDirectoryPath && !isSymlink
		}
		
		for bundleURL in bundleDirectories {
			urlsToInject.append(bundleURL)
		}
		
		let directoriesToSearch = allFiles.filter { url in
			let attributes = try? fileManager.attributesOfItem(atPath: url.path)
			let isSymlink = attributes?[.type] as? FileAttributeType == .typeSymbolicLink
			return url.hasDirectoryPath && !bundleDirectories.contains(url) && !isSymlink
		}
		
		for dirURL in directoriesToSearch {
			try searchForBundles(in: dirURL)
		}
	}

	private func locateDylibFiles(in directory: URL) throws -> [URL] {
		let fileManager = FileManager.default
		let files = try fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil, options: [])

		let dylibFiles = files.filter { url in
			let attributes = try? fileManager.attributesOfItem(atPath: url.path)
			let isSymlink = attributes?[.type] as? FileAttributeType == .typeSymbolicLink
			return url.pathExtension.lowercased() == "dylib" && !isSymlink
		}
		
		return dylibFiles
	}

	private func locateFrameworkDirectories(in directory: URL) throws -> [URL] {
		let fileManager = FileManager.default
		let files = try fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])

		let frameworkDirectories = files.filter { url in
			let attributes = try? fileManager.attributesOfItem(atPath: url.path)
			let isSymlink = attributes?[.type] as? FileAttributeType == .typeSymbolicLink
			return url.pathExtension.lowercased() == "framework" && url.hasDirectoryPath && !isSymlink
		}
		
		return frameworkDirectories
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
	
	public static func findExecutable(at frameworkURL: URL) throws -> URL? {
		
		let infoPlistURL = frameworkURL.appendingPathComponent("Info.plist")
		
		let plistData = try Data(contentsOf: infoPlistURL)
		if let plist = try PropertyListSerialization.propertyList(from: plistData, options: [], format: nil) as? [String: Any],
		   let executableName = plist["CFBundleExecutable"] as? String {
			let executableURL = frameworkURL.appendingPathComponent(executableName)
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
		}
	}
}

