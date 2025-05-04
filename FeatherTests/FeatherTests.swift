//
//  FeatherTests.swift
//  FeatherTests
//
//  Created by Lakhan Lothiyi on 19/04/2025.
//

import XCTest
@testable import Feather
@testable import Esign
 
final class FeatherTests: XCTestCase {

//	override func setUpWithError() throws {
//		// Put setup code here. This method is called before the invocation of each test method in the class.
//	}
//
//	override func tearDownWithError() throws {
//		// Put teardown code here. This method is called after the invocation of each test method in the class.
//	}
//
//	func testExample() throws {
//		// This is an example of a functional test case.
//		// Use XCTAssert and related functions to verify your tests produce the correct results.
//		// Any test you write for XCTest can be annotated as throws and async.
//		// Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
//		// Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
//		
//	}
//
//	func testPerformanceExample() throws {
//		// This is an example of a performance test case.
//		measure {
//			// Put the code you want to measure the time of here.
//		}
//	}

	func testRepoParsing() async throws {
		let repoDatas: [URL: Data] = try await withThrowingTaskGroup(of: (URL,Data).self, returning: [URL : Data].self) { group in
			for url in repoURLs {
				group.addTask {
					let (data, _) = try await URLSession.shared.data(from: url)
					return (url, data)
				}
			}
			
			var results: [URL: Data] = [:]
			for try await result in group {
				results[result.0] = result.1
			}
			
			return results
		}
		
		let decoder = JSONDecoder()
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd"
		decoder.dateDecodingStrategy = .formatted(dateFormatter)
		
		var accumulated: [Repository] = []
		for (url, data) in repoDatas {
			do {
				let repo = try decoder.decode(Repository.self, from: data)
				accumulated.append(repo)
			} catch {
				XCTFail("Failed to decode repo data: \(error)\n\nFailed for \(url)\n\n======================================\n\n")
			}
		}
		
		print("\(accumulated.count) repositories")
		for repo in accumulated {
			print("\(repo.name) (\(repo.apps.count) apps)")
			
		}
	}
	
	func testRepoDeobfuscation() async throws  {
		// theres multiple ways to obfuscate a list of strings, base64, other encryption, etc.
		// kravasign/maplesign use plain base64 to export repository "codes", newlines seperated
		// by `[K$]` and or `[M$]` (depending on what app you're currently using)
		
		// on the other hand Easy Sign (Esign) obfuscate their repository codes using more than
		// base64, stupidly complicated but they do use some obfuscation key and technique
		
		// we need to handle both cases, base64 and the latter, first we can check if whats
		// pasted starts with `source[`, then go from there. All we need is a list of repositories
		// seperated with newlines.
		
		let code = obfuscatedKUrl
		
		func decodeBase64Format(_ code: String) -> Result<[String], RepositoryDeobfuscationError> {
			guard
				let data = Data(base64Encoded: code),
				let decodedString = String(data: data, encoding: .utf8)
			else {
				return .failure(.base64DecodingFailure)
			}
			
			var repositories: [String]
			if decodedString.contains("[K$]") {
				repositories = decodedString.components(separatedBy: "[K$]")
			} else if decodedString.contains("[M$]") {
				repositories = decodedString.components(separatedBy: "[M$]")
			} else {
				repositories = decodedString.components(separatedBy: .newlines)
			}
			
			repositories = repositories.map {
				$0.trimmingCharacters(in: .whitespacesAndNewlines)
			}.filter { !$0.isEmpty }
			
			print(repositories)
			
			return repositories.isEmpty
			? .failure(.emptyResult)
			: .success(repositories)
		}
		
		let trimmedCode = code.trimmingCharacters(in: .whitespacesAndNewlines)
		
		// Empty input check
		guard !trimmedCode.isEmpty else {
			return
		}
		
		if trimmedCode.hasPrefix("source[") {
			let c = eRepoDecrypt(input: code)
			print(c.decrypt() ?? [])
			return
		} else {
			_ = decodeBase64Format(trimmedCode)
			return
		}
	}
}

// these are quite interesting.
let obfuscatedKUrl = "aHR0cHM6Ly9jZG4uYWx0c3RvcmUuaW8vZmlsZS9hbHRzdG9yZS9hcHBzLmpzb24="
let obfEUrl = "source[5GHxhb1U7Lc5jIMpumASbN2teg9dyK5EAazzwnfm1/gPKQPTWzcz/Gq3Njt97KapLNMztZCR3sHbMw/AMSpBsztQijHaOP/HgNtFseMyB1U=]"

let repoURLs: [URL] = [
	"https://cdn.altstore.io/file/altstore/apps.json",
].map { URL(string: $0)! }

enum RepositoryDeobfuscationError: Error {
	case invalidFormat
	case esignDecodingFailure
	case base64DecodingFailure
	case emptyResult
}
