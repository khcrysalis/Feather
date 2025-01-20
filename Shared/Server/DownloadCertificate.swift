//
//  DownloadCertificate.swift
//  feather
//
//  Created by samara on 8/18/24.
//

import Foundation

func getDocumentsDirectory() -> URL {
	let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
	let documentsDirectory = paths[0]
	return documentsDirectory
}

