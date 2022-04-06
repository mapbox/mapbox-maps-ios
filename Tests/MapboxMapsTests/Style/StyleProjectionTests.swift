import XCTest
@testable import MapboxMaps

final class StyleProjectionTests: XCTestCase {

    func testMemberwiseInit() {
        let name: StyleProjectionName = [.mercator, .globe].randomElement()!

        let projection = StyleProjection(name: name)

        XCTAssertEqual(projection.name, name)
    }

    func testCodable() throws {
        let name: StyleProjectionName = [.mercator, .globe].randomElement()!
        let projection = StyleProjection(name: name)

        let jsonData = try JSONEncoder().encode(projection)

        let jsonObject = try JSONSerialization.jsonObject(with: jsonData) as? [String: String]

        XCTAssertEqual(jsonObject, ["name": name.rawValue])

        let decodedProjection = try JSONDecoder().decode(StyleProjection.self, from: jsonData)

        XCTAssertEqual(decodedProjection, projection)
    }
}

final class StyleProjectionNameTests: XCTestCase {

    func testCodable() throws {
        let name: StyleProjectionName = [.mercator, .globe].randomElement()!

        let jsonData = try JSONEncoder().encode([name])

        let jsonObject = try JSONSerialization.jsonObject(with: jsonData) as? [String]

        XCTAssertEqual(jsonObject, [name.rawValue])

        let decodedName = try JSONDecoder().decode([StyleProjectionName].self, from: jsonData)

        XCTAssertEqual(decodedName, [name])
    }
}
