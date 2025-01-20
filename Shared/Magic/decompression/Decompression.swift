//
//  Decompression.swift
//  feather
//
//  Created by samara on 21.08.2024.
//  Copyright (c) 2024 Samara M (khcrysalis)
//

import Foundation
import SWCompression
import Compression

func processFile(at packagesFile: inout URL) throws {
	let succeededExtension = packagesFile.pathExtension.lowercased()
	let fileManager = FileManager.default

	func readData(from url: URL) throws -> Data {
		return try Data(contentsOf: url)
	}

	func writeData(_ data: Data, to url: URL) throws {
		try data.write(to: url)
	}

	func handleCompressedFile(extension: String, decompressor: (Data) throws -> Data) throws {
		let compressedData = try readData(from: packagesFile)
		let decompressedData = try decompressor(compressedData)
		let outputURL = packagesFile.deletingPathExtension()
		try writeData(decompressedData, to: outputURL)
		packagesFile = outputURL
	}

	func handleTarFile() throws {
		let tarData = try readData(from: packagesFile)
		let tarContainer = try TarContainer.open(container: tarData)

		let extractionDirectory = packagesFile.deletingLastPathComponent().appendingPathComponent(UUID().uuidString)
		try fileManager.createDirectory(at: extractionDirectory, withIntermediateDirectories: true, attributes: nil)

		for entry in tarContainer {
			let entryPath = extractionDirectory.appendingPathComponent(entry.info.name)
			if entry.info.type == .regular {
				if let entryData = entry.data {
					try writeData(entryData, to: entryPath)
				}
			} else if entry.info.type == .directory {
				try fileManager.createDirectory(at: entryPath, withIntermediateDirectories: true, attributes: nil)
			}
		}

		packagesFile = extractionDirectory
	}

	switch succeededExtension {
	case "xz":
		try handleCompressedFile(extension: succeededExtension, decompressor: XZArchive.unarchive)

	case "lzma":
		try handleCompressedFile(extension: succeededExtension, decompressor: LZMA.decompress)

	case "bz2":
		try handleCompressedFile(extension: succeededExtension, decompressor: BZip2.decompress)

	case "gz":
		try handleCompressedFile(extension: succeededExtension, decompressor: GzipArchive.unarchive)

	case "tar":
		try handleTarFile()

	default:
		throw FileProcessingError.unsupportedFileExtension(succeededExtension)
	}
}
