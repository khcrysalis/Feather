//
//  SSLCertificateGenerator.swift
//  Feather
//
//  Created for localhost SSL certificate management
//  Generates unique SSL certificates at runtime for each user
//

import Foundation
import Security
import OSLog

class SSLCertificateGenerator {
	
	/// Ensures localhost SSL certificates exist in the documents directory
	/// Generates new unique certificates at runtime if they don't exist
	static func ensureLocalhostCertificate() throws {
		let fileManager = FileManager.default
		let documentsURL = URL.documentsDirectory
		
		let certURL = documentsURL.appendingPathComponent("server.crt")
		let keyURL = documentsURL.appendingPathComponent("server.pem")
		let commonNameURL = documentsURL.appendingPathComponent("commonName.txt")
		
		// Check if certificates already exist in documents directory
		let certExists = fileManager.fileExists(atPath: certURL.path)
		let keyExists = fileManager.fileExists(atPath: keyURL.path)
		let commonNameExists = fileManager.fileExists(atPath: commonNameURL.path)
		
		// If all files exist, we're done - each user keeps their unique certificate
		if certExists && keyExists && commonNameExists {
			Logger.misc.info("SSL certificates already exist in documents directory (unique to this user)")
			return
		}
		
		// Generate NEW unique certificates at runtime for this user
		Logger.misc.info("Generating unique SSL certificate for localhost at runtime...")
		
		do {
			let (certificate, privateKey) = try generateSelfSignedCertificate(hostname: "localhost")
			
			// Write certificate and key to documents directory
			try certificate.write(to: certURL, atomically: true, encoding: .utf8)
			try privateKey.write(to: keyURL, atomically: true, encoding: .utf8)
			try "localhost".write(to: commonNameURL, atomically: true, encoding: .utf8)
			
			Logger.misc.info("Successfully generated unique SSL certificate for this user")
		} catch {
			Logger.misc.error("Failed to generate SSL certificate: \(error.localizedDescription)")
			throw SSLCertificateError.certificateGenerationFailed(error)
		}
	}
	
	/// Generates a self-signed certificate using OpenSSL-compatible format
	/// Returns (certificate PEM, private key PEM)
	private static func generateSelfSignedCertificate(hostname: String) throws -> (String, String) {
		// Generate RSA key pair using Security framework
		let keySize = 2048
		let keyAttributes: [String: Any] = [
			kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
			kSecAttrKeySizeInBits as String: keySize,
			kSecAttrIsPermanent as String: false // Don't store in keychain
		]
		
		var error: Unmanaged<CFError>?
		guard let privateKey = SecKeyCreateRandomKey(keyAttributes as CFDictionary, &error) else {
			if let error = error?.takeRetainedValue() {
				throw error as Error
			}
			throw SSLCertificateError.keyGenerationFailed
		}
		
		guard let publicKey = SecKeyCopyPublicKey(privateKey) else {
			throw SSLCertificateError.publicKeyExtractionFailed
		}
		
		// Export private key
		guard let privateKeyData = SecKeyCopyExternalRepresentation(privateKey, &error) as Data? else {
			if let error = error?.takeRetainedValue() {
				throw error as Error
			}
			throw SSLCertificateError.privateKeyExportFailed
		}
		
		// Export public key
		guard let publicKeyData = SecKeyCopyExternalRepresentation(publicKey, &error) as Data? else {
			if let error = error?.takeRetainedValue() {
				throw error as Error
			}
			throw SSLCertificateError.publicKeyExportFailed
		}
		
		// Generate the certificate (X.509 DER format)
		let certificateDER = try generateX509Certificate(
			publicKeyData: publicKeyData,
			privateKey: privateKey,
			hostname: hostname
		)
		
		// Convert to PEM format
		let certificatePEM = toPEM(data: certificateDER, label: "CERTIFICATE")
		let privateKeyPEM = toPEM(data: privateKeyData, label: "RSA PRIVATE KEY")
		
		return (certificatePEM, privateKeyPEM)
	}
	
	/// Generates an X.509 certificate in DER format
	private static func generateX509Certificate(
		publicKeyData: Data,
		privateKey: SecKey,
		hostname: String
	) throws -> Data {
		// Build certificate using ASN.1 DER encoding
		
		// Generate a random serial number (unique per certificate)
		let serialNumber = Int.random(in: 100000...Int.max)
		
		// Set validity period
		let notBefore = Date()
		let notAfter = Date(timeIntervalSinceNow: 365 * 24 * 60 * 60) // 1 year
		
		// Build the TBSCertificate (To Be Signed Certificate)
		var tbsCertificate = Data()
		
		// Version (v3 = 2)
		tbsCertificate.append(asn1Tagged(tag: 0, content: asn1Integer(2)))
		
		// Serial number (unique for each certificate)
		tbsCertificate.append(asn1Integer(serialNumber))
		
		// Signature algorithm (SHA256 with RSA)
		tbsCertificate.append(asn1Sequence([
			asn1ObjectIdentifier([1, 2, 840, 113549, 1, 1, 11]), // sha256WithRSAEncryption
			asn1Null()
		]))
		
		// Issuer (CN=localhost)
		let issuerDN = asn1Sequence([
			asn1Set([
				asn1Sequence([
					asn1ObjectIdentifier([2, 5, 4, 3]), // commonName
					asn1UTF8String(hostname)
				])
			])
		])
		tbsCertificate.append(issuerDN)
		
		// Validity
		tbsCertificate.append(asn1Sequence([
			asn1UTCTime(notBefore),
			asn1UTCTime(notAfter)
		]))
		
		// Subject (same as issuer for self-signed)
		tbsCertificate.append(issuerDN)
		
		// Subject Public Key Info
		let publicKeyInfo = asn1Sequence([
			asn1Sequence([
				asn1ObjectIdentifier([1, 2, 840, 113549, 1, 1, 1]), // rsaEncryption
				asn1Null()
			]),
			asn1BitString(encodeRSAPublicKey(publicKeyData))
		])
		tbsCertificate.append(publicKeyInfo)
		
		// Extensions (v3)
		let extensions = asn1Tagged(tag: 3, content: asn1Sequence([
			// Subject Alternative Name
			asn1Sequence([
				asn1ObjectIdentifier([2, 5, 29, 17]), // subjectAltName
				asn1OctetString(asn1Sequence([
					asn1ContextSpecific(tag: 2, content: hostname.data(using: .utf8)!), // dNSName
					asn1ContextSpecific(tag: 7, content: Data([127, 0, 0, 1])) // iPAddress (127.0.0.1)
				]))
			])
		]))
		tbsCertificate.append(extensions)
		
		// Wrap TBS in sequence
		let tbsSequence = asn1Sequence([tbsCertificate])
		
		// Sign the TBS certificate
		let algorithm: SecKeyAlgorithm = .rsaSignatureMessagePKCS1v15SHA256
		guard let signature = SecKeyCreateSignature(
			privateKey,
			algorithm,
			tbsSequence as CFData,
			&error
		) as Data? else {
			if let error = error?.takeRetainedValue() {
				throw error as Error
			}
			throw SSLCertificateError.signatureFailed
		}
		
		// Build the final certificate
		let certificate = asn1Sequence([
			tbsSequence,
			asn1Sequence([
				asn1ObjectIdentifier([1, 2, 840, 113549, 1, 1, 11]), // sha256WithRSAEncryption
				asn1Null()
			]),
			asn1BitString(signature)
		])
		
		return certificate
	}
	
	// MARK: - ASN.1 Encoding Helpers
	
	private static func asn1Sequence(_ elements: [Data]) -> Data {
		let content = elements.reduce(Data(), +)
		return asn1Encode(tag: 0x30, content: content)
	}
	
	private static func asn1Set(_ elements: [Data]) -> Data {
		let content = elements.reduce(Data(), +)
		return asn1Encode(tag: 0x31, content: content)
	}
	
	private static func asn1Integer(_ value: Int) -> Data {
		var bytes = withUnsafeBytes(of: value.bigEndian) { Data($0) }
		while bytes.count > 1 && bytes[0] == 0 && bytes[1] & 0x80 == 0 {
			bytes.removeFirst()
		}
		if bytes[0] & 0x80 != 0 {
			bytes.insert(0, at: 0)
		}
		return asn1Encode(tag: 0x02, content: bytes)
	}
	
	private static func asn1ObjectIdentifier(_ oid: [Int]) -> Data {
		var bytes = Data()
		bytes.append(UInt8(oid[0] * 40 + oid[1]))
		for component in oid.dropFirst(2) {
			var value = component
			var temp = [UInt8]()
			temp.append(UInt8(value & 0x7F))
			value >>= 7
			while value > 0 {
				temp.insert(UInt8((value & 0x7F) | 0x80), at: 0)
				value >>= 7
			}
			bytes.append(contentsOf: temp)
		}
		return asn1Encode(tag: 0x06, content: bytes)
	}
	
	private static func asn1UTF8String(_ string: String) -> Data {
		let content = string.data(using: .utf8)!
		return asn1Encode(tag: 0x0C, content: content)
	}
	
	private static func asn1UTCTime(_ date: Date) -> Data {
		let formatter = DateFormatter()
		formatter.dateFormat = "yyMMddHHmmss'Z'"
		formatter.timeZone = TimeZone(secondsFromGMT: 0)
		let timeString = formatter.string(from: date)
		let content = timeString.data(using: .ascii)!
		return asn1Encode(tag: 0x17, content: content)
	}
	
	private static func asn1BitString(_ data: Data) -> Data {
		var content = Data([0x00]) // No unused bits
		content.append(data)
		return asn1Encode(tag: 0x03, content: content)
	}
	
	private static func asn1OctetString(_ data: Data) -> Data {
		return asn1Encode(tag: 0x04, content: data)
	}
	
	private static func asn1Null() -> Data {
		return Data([0x05, 0x00])
	}
	
	private static func asn1Tagged(tag: Int, content: Data) -> Data {
		return asn1Encode(tag: UInt8(0xA0 + tag), content: content)
	}
	
	private static func asn1ContextSpecific(tag: Int, content: Data) -> Data {
		return asn1Encode(tag: UInt8(0x80 + tag), content: content)
	}
	
	private static func asn1Encode(tag: UInt8, content: Data) -> Data {
		var result = Data([tag])
		let length = content.count
		
		if length < 128 {
			result.append(UInt8(length))
		} else if length < 256 {
			result.append(0x81)
			result.append(UInt8(length))
		} else if length < 65536 {
			result.append(0x82)
			result.append(UInt8(length >> 8))
			result.append(UInt8(length & 0xFF))
		} else {
			result.append(0x83)
			result.append(UInt8(length >> 16))
			result.append(UInt8((length >> 8) & 0xFF))
			result.append(UInt8(length & 0xFF))
		}
		
		result.append(content)
		return result
	}
	
	private static func encodeRSAPublicKey(_ publicKeyData: Data) -> Data {
		// RSA public key structure: SEQUENCE { modulus INTEGER, exponent INTEGER }
		// iOS exports the key in a specific format, we need to wrap it properly
		return asn1Sequence([
			asn1Integer(0), // We'll use the raw data as-is
			publicKeyData
		])
	}
	
	private static func toPEM(data: Data, label: String) -> String {
		let base64 = data.base64EncodedString(options: [.lineLength64Characters, .endLineWithLineFeed])
		return "-----BEGIN \(label)-----\n\(base64)-----END \(label)-----\n"
	}
	
	/// Removes existing certificates from documents directory
	/// This will force regeneration of new unique certificates on next use
	static func removeCertificates() {
		let fileManager = FileManager.default
		let documentsURL = URL.documentsDirectory
		
		let certURL = documentsURL.appendingPathComponent("server.crt")
		let keyURL = documentsURL.appendingPathComponent("server.pem")
		let commonNameURL = documentsURL.appendingPathComponent("commonName.txt")
		
		try? fileManager.removeItem(at: certURL)
		try? fileManager.removeItem(at: keyURL)
		try? fileManager.removeItem(at: commonNameURL)
		
		Logger.misc.info("Removed SSL certificates from documents directory")
	}
}

enum SSLCertificateError: Error {
	case keyGenerationFailed
	case publicKeyExtractionFailed
	case privateKeyExportFailed
	case signatureFailed
	case certificateGenerationFailed(Error)
	
	var localizedDescription: String {
		switch self {
		case .keyGenerationFailed:
			return "Failed to generate RSA key pair"
		case .publicKeyExtractionFailed:
			return "Failed to extract public key"
		case .privateKeyExportFailed:
			return "Failed to export private key"
		case .signatureFailed:
			return "Failed to sign certificate"
		case .certificateGenerationFailed(let error):
			return "Failed to generate certificate: \(error.localizedDescription)"
		}
	}
}
