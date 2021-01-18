import XCTest
import Foundation

// Disabling rules against force casting for test file.
// swiftlint:disable force_cast explicit_acl explicit_top_level_acl
class Fixture {
    class func stringFromFileNamed(name: String) -> String {
        guard let path = Bundle(for: self).path(forResource: name, ofType: "json") ??
            Bundle(for: self).path(forResource: name, ofType: "geojson") else {
            XCTAssert(false, "Fixture \(name) not found.")
            return ""
        }
        do {
            return try String(contentsOfFile: path, encoding: .utf8)
        } catch {
            XCTAssert(false, "Unable to decode fixture at \(path): \(error).")
            return ""
        }
    }

    class func geojsonData(from name: String) throws -> Data? {
        guard let path = Bundle(for: self).path(forResource: name, ofType: "geojson") else {
            XCTAssert(false, "Fixture \(name) not found.")
            return nil
        }
        let filePath = URL(fileURLWithPath: path)
        return try Data(contentsOf: filePath)
    }

    class func JSONFromFileNamed(name: String) -> [String: Any] {
        guard let path = Bundle(for: self).path(forResource: name, ofType: "json") ??
            Bundle(for: self).path(forResource: name, ofType: "geojson") else {
            XCTAssert(false, "Fixture \(name) not found.")
            return [:]
        }
        guard let data = NSData(contentsOfFile: path) else {
            XCTAssert(false, "No data found at \(path).")
            return [:]
        }
        do {
            return try JSONSerialization.jsonObject(with: data as Data, options: []) as! [String: AnyObject]
        } catch {
            XCTAssert(false, "Unable to decode JSON fixture at \(path): \(error).")
            return [:]
        }
    }
}
