import XCTest
import MapboxMaps

extension XCTestCase {
    func mapboxAccessToken() throws -> String {
        func token() throws -> String {
            // User defaults can override plist
            if let token = UserDefaults.standard.string(forKey: "MBXAccessToken") {
                print("Found access token from UserDefaults (command line parameter?)")
                return token
            } else if let token = Bundle.mapboxMapsTests.infoDictionary?["MBXAccessToken"] as? String {
                print("Found access token in Info.plist")
                return token
            } else if let url = Bundle.mapboxMapsTests.url(forResource: "MapboxAccessToken", withExtension: nil),
                      let token = try? String(contentsOf: url) {
                print("Found access token in MapboxAccessToken")
                return token
            } else {
                throw XCTSkip("Mapbox access token not found")
            }
        }

        func validated(token: String) throws -> String {
            if token.starts(with: "pk.") {
                // ok
            } else if token.isEmpty {
                print("⚠️ token is empty.")
            } else {
                throw XCTSkip("Mapbox access token is invalid")
            }
            return token
        }

        return try validated(token: token()).trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
