import XCTest
@testable import MapboxMaps

final class StyleProjectionTests: XCTestCase {

    func testMemberwiseInit() {
        let string = String.randomASCII(withLength: .random(in: 0...10))
        let name = StyleProjectionName(rawValue: string)

        let projection = StyleProjection(name: name)

        XCTAssertEqual(projection.name, name)
    }

    func testCodable() throws {
        let string = String.randomASCII(withLength: .random(in: 0...10))
        let name = StyleProjectionName(rawValue: string)
        let projection = StyleProjection(name: name)

        let jsonData = try JSONEncoder().encode(projection)

        let jsonObject = try JSONSerialization.jsonObject(with: jsonData) as? [String: String]

        XCTAssertEqual(jsonObject, ["name": string])

        let decodedProjection = try JSONDecoder().decode(StyleProjection.self, from: jsonData)

        XCTAssertEqual(decodedProjection, projection)
    }
}

final class StyleProjectionNameTests: XCTestCase {

    func testInitWithRawValue() {
        let string = String.randomASCII(withLength: .random(in: 0...10))

        let name = StyleProjectionName(rawValue: string)

        XCTAssertEqual(name.rawValue, string)
    }

    func testStaticValues() {
        XCTAssertEqual(StyleProjectionName.mercator.rawValue, "mercator")
        XCTAssertEqual(StyleProjectionName.globe.rawValue, "globe")
    }

    func testCodable() throws {
        let string = String.randomASCII(withLength: .random(in: 0...10))

        let name = StyleProjectionName(rawValue: string)

        let jsonData = try JSONEncoder().encode([name])

        let jsonObject = try JSONSerialization.jsonObject(with: jsonData) as? [String]

        XCTAssertEqual(jsonObject, [string])

        let decodedName = try JSONDecoder().decode([StyleProjectionName].self, from: jsonData)

        XCTAssertEqual(decodedName, [name])
    }
}
