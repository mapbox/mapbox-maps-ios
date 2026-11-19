import XCTest
@_spi(Experimental) @testable import MapboxMaps

final class StyleProjectionTests: XCTestCase {

    func testMemberwiseInit() {
        let name: StyleProjectionName = .mercator

        let projection = StyleProjection(name: name)

        XCTAssertEqual(projection.name, name)
    }

    func testCodable() throws {
        let name: StyleProjectionName = .globe
        let projection = StyleProjection(name: name)

        let jsonData = try JSONEncoder().encode(projection)

        let jsonObject = try JSONSerialization.jsonObject(with: jsonData) as? [String: String]

        XCTAssertEqual(jsonObject, ["name": name.rawValue])

        let decodedProjection = try JSONDecoder().decode(StyleProjection.self, from: jsonData)

        XCTAssertEqual(decodedProjection, projection)
    }

    func testAlbersCodable() throws {
        let projection = StyleProjection.albers(center: CLLocationCoordinate2D(latitude: 50, longitude: 10), parallels: 43...62)

        let jsonData = try JSONEncoder().encode(projection)

        let jsonObject = try JSONSerialization.jsonObject(with: jsonData) as? NSDictionary

        XCTAssertEqual(jsonObject, ["name": "albers", "center": [10, 50], "parallels": [43, 62]])

        let decodedProjection = try JSONDecoder().decode(StyleProjection.self, from: jsonData)

        XCTAssertEqual(decodedProjection, projection)
    }
}

final class StyleProjectionNameTests: XCTestCase {

    func testCodable() throws {
        let name: StyleProjectionName = .mercator

        let jsonData = try JSONEncoder().encode([name])

        let jsonObject = try JSONSerialization.jsonObject(with: jsonData) as? [String]

        XCTAssertEqual(jsonObject, [name.rawValue])

        let decodedName = try JSONDecoder().decode([StyleProjectionName].self, from: jsonData)

        XCTAssertEqual(decodedName, [name])
    }
}
