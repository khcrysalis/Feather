//
//  FeatherTests.swift
//  FeatherTests
//
//  Created by Lakhan Lothiyi on 19/04/2025.
//

import XCTest
@testable import Feather

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
}


let repoURLs: [URL] = [
	"https://cdn.altstore.io/file/altstore/apps.json",
].map { URL(string: $0)! }
