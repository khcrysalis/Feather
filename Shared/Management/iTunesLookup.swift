import Foundation

struct iTunesLookupResult: Codable {
    let resultCount: Int
    let results: [iTunesResult]
}

struct iTunesResult: Codable {
    let bundleId: String
    
    enum CodingKeys: String, CodingKey {
        case bundleId = "bundleId"
    }
}

class iTunesLookup {
    static func checkBundleId(_ bundleId: String) async throws -> Bool {
        let encodedBundleId = bundleId.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? bundleId
        let urlString = "https://itunes.apple.com/lookup?bundleId=\(encodedBundleId)"
        
        guard let url = URL(string: urlString) else {
            throw NSError(domain: "iTunesLookup", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw NSError(domain: "iTunesLookup", code: -2, userInfo: [NSLocalizedDescriptionKey: "Invalid response from iTunes API"])
        }
        
        let result = try JSONDecoder().decode(iTunesLookupResult.self, from: data)
        return result.resultCount > 0
    }
} 